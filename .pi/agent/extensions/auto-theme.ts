import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

/**
 * Auto-theme extension: switches between dark/light themes based on system settings.
 * 
 * Supports:
 * - darkman (darkman get)
 * 
 * Add to your settings or just drop in ~/.pi/agent/extensions/
 */
export default function (pi: ExtensionAPI) {
  let currentTheme: "dark" | "light" | null = null;
  let intervalId: ReturnType<typeof setInterval> | null = null;

  // Detect system theme preference
  async function detectSystemTheme(): Promise<"dark" | "light"> {
    try {
      const result = await pi.exec("darkman", ["get"]);
      const mode = result.stdout.trim().toLowerCase();
      if (mode === "dark" || mode === "light") return mode;
    } catch {
      // darkman not available
    }

    // Default fallback
    return "dark";
  }

  // Check and update theme if needed
  async function updateTheme(ctx: { ui: { setTheme: (name: string) => void } }) {
    try {
      const detected = await detectSystemTheme();
      if (detected !== currentTheme) {
        currentTheme = detected;
        ctx.ui.setTheme(detected === "dark" ? "flexoki-dark" : "flexoki-light");
      }
    } catch (error) {
      // Silently fail - system detection may not work in all environments
    }
  }

  // On session start, detect and start polling
  pi.on("session_start", async (_event, ctx) => {
    // Initial detection
    await updateTheme(ctx);

    // Poll every 30 seconds (adjust as needed)
    intervalId = setInterval(() => {
      updateTheme(ctx);
    }, 30000);
  });

  // Cleanup on shutdown
  pi.on("session_shutdown", async () => {
    if (intervalId) {
      clearInterval(intervalId);
      intervalId = null;
    }
  });
}
