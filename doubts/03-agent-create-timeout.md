## Symptom
`opencode agent create` fails with:
"LLM failed to generate agent: Provider response headers timed out after 300000ms"

## Cause
The interactive agent-creation wizard uses the model to draft the agent config. On a slow local model (especially under VM resource constraints), this generation can exceed opencode's 5-minute timeout.

## Fix
Skip the wizard — write the agent file directly instead. Agent configs are just markdown files with YAML frontmatter:

    mkdir -p .opencode/agent

Then create a file like .opencode/agent/<name>.md with:

    ---
    description: ...
    mode: primary
    ---
    (system prompt text)

opencode picks these up automatically — no wizard needed.

## How to prevent it next time
On a resource-constrained local model, skip `agent create` entirely and always write agent files by hand from the start — this is exactly what this repo's agents/ folder already provides.
