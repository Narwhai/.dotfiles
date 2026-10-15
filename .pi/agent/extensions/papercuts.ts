import { StringEnum } from "@earendil-works/pi-ai";
import {
	DEFAULT_MAX_BYTES,
	DEFAULT_MAX_LINES,
	getAgentDir,
	truncateHead,
	type ExtensionAPI,
	withFileMutationQueue,
} from "@earendil-works/pi-coding-agent";
import { Buffer } from "node:buffer";
import { randomUUID } from "node:crypto";
import { appendFile, mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname, join, resolve } from "node:path";
import { Type } from "typebox";

const PAPERCUT_LOG_PATH = join(getAgentDir(), "papercuts.jsonl");
const PAPERCUT_REPORT_PATH = join(getAgentDir(), "papercuts.md");
const MAX_LIST_LIMIT = 100;

type PapercutCategory =
	| "dependency"
	| "environment"
	| "configuration"
	| "tooling"
	| "permissions"
	| "documentation"
	| "test"
	| "other";

interface PapercutRecord {
	version: 1;
	id: string;
	recordedAt: string;
	project: string;
	sessionId: string;
	category: PapercutCategory;
	summary: string;
	impact: string;
	evidence: string;
	workaround: string;
}

function stringValues<T extends string[]>(...values: T): T {
	return values;
}

const PapercutCategoryValues = stringValues(
	"dependency",
	"environment",
	"configuration",
	"tooling",
	"permissions",
	"documentation",
	"test",
	"other",
);

const RecordPapercutParameters = Type.Object({
	category: StringEnum(PapercutCategoryValues, {
		description: "Kind of obstacle encountered",
	}),
	summary: Type.String({
		minLength: 1,
		maxLength: 500,
		description: "Concise description of the papercut",
	}),
	impact: Type.String({
		minLength: 1,
		maxLength: 1500,
		description: "How the obstacle affected the task",
	}),
	evidence: Type.String({
		minLength: 1,
		maxLength: 4000,
		description: "Observed error, command output, or reproducible facts; redact secrets",
	}),
	workaround: Type.String({
		minLength: 1,
		maxLength: 4000,
		description: "The actual workaround or resolution used; state explicitly when none was found",
	}),
});

const ListPapercutsParameters = Type.Object({
	limit: Type.Integer({
		minimum: 1,
		maximum: MAX_LIST_LIMIT,
		description: "Maximum number of matching papercuts to return (1-100)",
	}),
	query: Type.Optional(
		Type.String({
			minLength: 1,
			maxLength: 500,
			description: "Case-insensitive text to match against project, category, summary, impact, evidence, or workaround",
		}),
	),
});

function getErrorMessage(error: unknown): string {
	return error instanceof Error ? error.message : String(error);
}

function isObject(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== null && !Array.isArray(value);
}

function requireText(value: unknown, field: string): string {
	if (typeof value !== "string") {
		throw new Error(`${field} must be a string.`);
	}

	const trimmed = value.trim();
	if (!trimmed) {
		throw new Error(`${field} must not be empty.`);
	}

	return trimmed;
}

function parseCategory(value: unknown): PapercutCategory {
	if (typeof value !== "string") {
		throw new Error("category must be a string.");
	}

	switch (value) {
		case "dependency":
		case "environment":
		case "configuration":
		case "tooling":
		case "permissions":
		case "documentation":
		case "test":
		case "other":
			return value;
		default:
			throw new Error(`Unknown papercut category: ${value}`);
	}
}

function parsePapercutRecord(value: unknown, lineNumber: number): PapercutRecord {
	if (!isObject(value)) {
		throw new Error(`Papercut log line ${lineNumber} must be an object.`);
	}

	if (value.version !== 1) {
		throw new Error(`Papercut log line ${lineNumber} has an unsupported version.`);
	}

	return {
		version: 1,
		id: requireText(value.id, `Papercut log line ${lineNumber} id`),
		recordedAt: requireText(value.recordedAt, `Papercut log line ${lineNumber} recordedAt`),
		project: requireText(value.project, `Papercut log line ${lineNumber} project`),
		sessionId: requireText(value.sessionId, `Papercut log line ${lineNumber} sessionId`),
		category: parseCategory(value.category),
		summary: requireText(value.summary, `Papercut log line ${lineNumber} summary`),
		impact: requireText(value.impact, `Papercut log line ${lineNumber} impact`),
		evidence: requireText(value.evidence, `Papercut log line ${lineNumber} evidence`),
		workaround: requireText(value.workaround, `Papercut log line ${lineNumber} workaround`),
	};
}

function isErrorWithCode(error: unknown, code: string): boolean {
	return isObject(error) && error.code === code;
}

async function readPapercuts(): Promise<PapercutRecord[]> {
	let content: string;
	try {
		content = await readFile(PAPERCUT_LOG_PATH, "utf8");
	} catch (error: unknown) {
		if (isErrorWithCode(error, "ENOENT")) {
			return [];
		}
		throw new Error(`Unable to read papercut log at ${PAPERCUT_LOG_PATH}: ${getErrorMessage(error)}`);
	}

	const records: PapercutRecord[] = [];
	const lines = content.split(/\r?\n/);
	for (let index = 0; index < lines.length; index += 1) {
		const line = lines[index];
		if (!line || !line.trim()) {
			continue;
		}

		let parsed: unknown;
		try {
			parsed = JSON.parse(line);
		} catch (error: unknown) {
			throw new Error(`Papercut log line ${index + 1} is not valid JSON: ${getErrorMessage(error)}`);
		}
		records.push(parsePapercutRecord(parsed, index + 1));
	}

	return records;
}

function formatPapercut(record: PapercutRecord): string {
	return [
		`[${record.recordedAt}] ${record.category}: ${record.summary}`,
		`ID: ${record.id}`,
		`Project: ${record.project}`,
		`Session: ${record.sessionId}`,
		`Impact: ${record.impact}`,
		`Evidence: ${record.evidence}`,
		`Workaround: ${record.workaround}`,
	].join("\n");
}

function formatMarkdownBlock(value: string): string {
	return value.split(/\r?\n/).map((line) => `> ${line}`).join("\n");
}

function formatPapercutMarkdown(record: PapercutRecord): string {
	return [
		`## ${record.recordedAt} — ${record.category}`,
		"",
		"### Summary",
		formatMarkdownBlock(record.summary),
		"",
		"### Context",
		formatMarkdownBlock(`ID: ${record.id}\nProject: ${record.project}\nSession: ${record.sessionId}`),
		"",
		"### Impact",
		formatMarkdownBlock(record.impact),
		"",
		"### Evidence",
		formatMarkdownBlock(record.evidence),
		"",
		"### Workaround",
		formatMarkdownBlock(record.workaround),
	].join("\n");
}

function formatPapercutReport(records: PapercutRecord[]): string {
	const header = [
		"# Pi Papercuts",
		"",
		"> Generated from `papercuts.jsonl`. Do not edit this report; use the papercut tools to add records.",
		"",
	].join("\n");
	if (records.length === 0) {
		return `${header}No papercuts recorded.\n`;
	}

	const entries = [...records]
		.sort((left, right) => right.recordedAt.localeCompare(left.recordedAt))
		.map(formatPapercutMarkdown)
		.join("\n\n---\n\n");
	return `${header}${entries}\n`;
}

async function writePapercutReport(records: PapercutRecord[]): Promise<void> {
	await mkdir(dirname(PAPERCUT_REPORT_PATH), { recursive: true });
	await withFileMutationQueue(PAPERCUT_REPORT_PATH, async () => {
		await writeFile(PAPERCUT_REPORT_PATH, formatPapercutReport(records), "utf8");
	});
}

async function appendPapercut(record: PapercutRecord): Promise<void> {
	await mkdir(dirname(PAPERCUT_LOG_PATH), { recursive: true });
	await withFileMutationQueue(PAPERCUT_LOG_PATH, async () => {
		await appendFile(PAPERCUT_LOG_PATH, `${JSON.stringify(record)}\n`, "utf8");
		await writePapercutReport(await readPapercuts());
	});
}

function matchesQuery(record: PapercutRecord, query: string | undefined): boolean {
	if (query === undefined) {
		return true;
	}

	const searchable = [
		record.project,
		record.category,
		record.summary,
		record.impact,
		record.evidence,
		record.workaround,
	].join("\n");
	return searchable.toLocaleLowerCase().includes(query.toLocaleLowerCase());
}

function truncateListOutput(content: string): string {
	const notice = `\n\n[Output truncated. Full records are in ${PAPERCUT_LOG_PATH}.]`;
	const noticeBytes = Buffer.byteLength(notice, "utf8");
	const reservedLines = 2;
	if (noticeBytes >= DEFAULT_MAX_BYTES || reservedLines >= DEFAULT_MAX_LINES) {
		throw new Error("Papercut truncation notice exceeds the available output limit.");
	}

	const result = truncateHead(content, {
		maxBytes: DEFAULT_MAX_BYTES - noticeBytes,
		maxLines: DEFAULT_MAX_LINES - reservedLines,
	});
	return result.truncated ? `${result.content}${notice}` : content;
}

function formatPapercutList(records: PapercutRecord[], query: string | undefined): string {
	if (records.length === 0) {
		const scope = query === undefined ? "" : ` matching ${JSON.stringify(query)}`;
		return `No papercuts found${scope}. Log: ${PAPERCUT_LOG_PATH}`;
	}

	const scope = query === undefined ? "" : ` matching ${JSON.stringify(query)}`;
	const content = `Papercuts (${records.length})${scope}. Log: ${PAPERCUT_LOG_PATH}\n\n${records
		.map(formatPapercut)
		.join("\n\n")}`;
	return truncateListOutput(content);
}

function validateLimit(limit: number): number {
	if (!Number.isSafeInteger(limit) || limit < 1 || limit > MAX_LIST_LIMIT) {
		throw new Error(`limit must be an integer from 1 to ${MAX_LIST_LIMIT}.`);
	}
	return limit;
}

export default function papercutsExtension(pi: ExtensionAPI) {
	pi.on("session_start", async () => {
		await writePapercutReport(await readPapercuts());
	});

	pi.registerTool({
		name: "record_papercut",
		label: "Record Papercut",
		description:
			`Record a durable issue in the global papercut log at ${PAPERCUT_LOG_PATH}. ` +
			`The entry automatically includes the current project working directory and session ID, and is rendered for reading at ${PAPERCUT_REPORT_PATH}.`,
		promptSnippet: "Record a durable environment, dependency, setup, tooling, permission, test, or documentation obstacle",
		promptGuidelines: [
			"Use record_papercut after resolving or clearly identifying a material environment, dependency, setup, tooling, permission, test, or documentation obstacle. Include observed evidence and the actual workaround; never record secrets, credentials, or speculative transient failures.",
		],
		parameters: RecordPapercutParameters,

		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			const record: PapercutRecord = {
				version: 1,
				id: randomUUID(),
				recordedAt: new Date().toISOString(),
				project: resolve(ctx.cwd),
				sessionId: ctx.sessionManager.getSessionId(),
				category: parseCategory(params.category),
				summary: requireText(params.summary, "summary"),
				impact: requireText(params.impact, "impact"),
				evidence: requireText(params.evidence, "evidence"),
				workaround: requireText(params.workaround, "workaround"),
			};

			await appendPapercut(record);
			return {
				content: [
					{
						type: "text",
						text: `Recorded papercut ${record.id} for ${record.project}. Read the Markdown report at ${PAPERCUT_REPORT_PATH}.`,
					},
				],
				details: { record, logPath: PAPERCUT_LOG_PATH },
			};
		},
	});

	pi.registerTool({
		name: "list_papercuts",
		label: "List Papercuts",
		description:
			`Search the global papercut log at ${PAPERCUT_LOG_PATH}, including entries from every project. ` +
			"Use query to find recurring issues, projects, or workarounds.",
		promptSnippet: "Search documented papercuts across projects",
		parameters: ListPapercutsParameters,

		async execute(_toolCallId, params) {
			const limit = validateLimit(params.limit);
			const query = params.query === undefined ? undefined : requireText(params.query, "query");
			const records = await readPapercuts();
			const matchingRecords = records
				.filter((record) => matchesQuery(record, query))
				.sort((left, right) => right.recordedAt.localeCompare(left.recordedAt))
				.slice(0, limit);

			return {
				content: [{ type: "text", text: formatPapercutList(matchingRecords, query) }],
				details: {
					logPath: PAPERCUT_LOG_PATH,
					matchingCount: matchingRecords.length,
					query,
				},
			};
		},
	});
}
