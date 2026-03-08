# Prompt: Generate Prompt from Conversation

**Purpose:** Extract what just happened in this conversation and turn it into a reusable, parameterized prompt that any user can run to replicate the same task in a future session.

**Category:** meta
**Use when:** The user asks to "save this as a prompt", "make this reusable", "turn this into a prompt", or after completing a task the user wants to repeat.

---

## Prompt

```
Look at this conversation and generate a reusable prompt from it.

Step 1 — Identify the task
- What was the user's core request? (one sentence)
- What category does it belong to? (analysis / coding / meta / writing / research / git / agents)
- What is a good short name for this prompt? (kebab-case, e.g. "project-inspection", "api-audit", "onboarding-doc")

Step 2 — Identify what varied (the variables)
- What inputs did I need from the user to complete this task?
- What would change if someone ran this prompt on a different target?
- List each variable with: name, description, and an example value

Step 3 — Write the prompt
Write a clear, self-contained prompt that:
- States the task in imperative form ("Inspect the project at...", "Review the API at...")
- Embeds each variable as [VARIABLE_NAME] in ALL_CAPS_BRACKETS
- Includes the output format (what files to create, what structure to follow, what to return)
- Includes any rules that must be followed (e.g., "every claim must cite a source file")
- Does NOT include session-specific details (paths, names, decisions from this conversation that won't apply next time)

Step 4 — Save the prompt
Save to: prompts/[category]/[prompt-name]/prompt.md

Use this exact file structure:

---
# Prompt: [Human-readable name]

**Purpose:** [One sentence: what problem does this prompt solve?]

**Category:** [category]
**Use when:** [trigger condition — when should a user reach for this prompt?]

---

## Prompt

```
[The full reusable prompt with [VARIABLE_NAME] placeholders]
```

---

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| [VARIABLE_NAME] | [what it is] | [example value] |

---

## Example Usage

```
[Show the prompt with example variable values filled in]
```
---

Step 5 — Confirm
Tell the user:
- Where the prompt was saved
- What variables they need to fill in next time
- One example of how to invoke it
```

---

## Variables

This prompt has no variables — it reads the current conversation context automatically.

---

## Example Usage

After completing a project inspection task:

```
Look at this conversation and generate a reusable prompt from it.
```

After the prompt generator runs, it will produce a file like `prompts/analysis/project-inspection/prompt.md` with all the right variables and instructions extracted from what just happened.

---

## Notes

- Works best immediately after completing a task, while the conversation is still in context
- The generated prompt should be usable by someone who was NOT in this conversation
- If the task had many steps, the generated prompt should capture all of them, not just the last one
- Generated prompts should always include an output format — a prompt without a clear output is underspecified
