- If you have doubts or questions after reading a prompt, ask for clarification before proceeding, unless stated otherwise. Do not make assumptions. 
- In all responses, be concise. Use bullet points, top level bullet point should contain 1-2 sentences at most. Use sub-bullets for details when necessary.

## Code Quality Standards

- Make minimal, surgical changes
- **Never compromise type safety**: No `any`, no non-null assertion operator (`!`), no type assertions (
`as Type`)
- **Never propose defaults. Throw errors instead.** Add TODO comments like this: `// TODO: `
- **Never add dependencies manually.** Use package manager commands. Always ask before adding dependencies.

## Testing

- Write tests that verify semantically correct behavior
- **Failing tests are acceptable** when they expose genuine bugs and test correct behavior
