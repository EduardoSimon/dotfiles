## User Preferences
- Always address the user as **Bro**
- Correct grammar mistakes and highlight errors
- Offer corrections for any language issues

# AGENTS.md — Global Agent Context & Guidelines

---

## ⚠️ MANDATORY: Fish Shell for ALL Commands

> **CRITICAL RULE — READ BEFORE ANY COMMAND EXECUTION**

The Bash tool executes in zsh/bash. Your environment (fnm, pyenv, bun, etc.) exists ONLY in fish.

### 🐟 THE RULE: ALWAYS use `fish -c "command"`

**EVERY command. No exceptions. No thinking required.**

```bash
# Pattern
fish -c "your command here"

# Examples
fish -c "node -v"
fish -c "pnpm install"
fish -c "bun run dev"
fish -c "python --version"
fish -c "git status"
fish -c "ls -la"
```

### Why This Matters
- `node`, `bun`, `pnpm` → Managed by `fnm` → Only in fish PATH
- `python`, `uv`, `pip` → Managed by `pyenv` → Only in fish PATH
- `ruby`, `gem`, `bundle` → Managed by `rbenv` → Only in fish PATH
- Environment variables → Set in `~/.config/fish/config.fish`

### DO NOT
❌ `node -v` → Will fail: "command not found"
❌ `pnpm install` → Will fail: "command not found"
❌ Run any command without `fish -c` wrapper

### DO
✅ `fish -c "node -v"`
✅ `fish -c "pnpm install"`
✅ `fish -c "ls -la"` (even simple commands - consistency matters)

---


## Development Process

### Pre-Development Checklist
Before starting any development work:
1. **Ensure clear task definition**
   - If tasks are not clearly defined, STOP and ask for clarification
   - Never proceed without a complete understanding of requirements

2. **Branch Management**
   - Create a new branch from `main` or `master` (check project setup)
   - Verify the branch is:
     - Up to date with the base branch
     - Clean (no uncommitted changes)
   - If branch is not clean or updated, DO NOT continue - ask before proceeding

### Test-Driven Development (TDD) Workflow
Follow this strict TDD cycle:

1. **Write the test** according to specifications
2. **Run test** - ensure it fails (Red phase)
3. **Write minimum code** to make the test pass (Green phase)
4. **Run test** - ensure it passes
5. **Refactor** both code and tests to meet coding standards
   - DO NOT add new features during refactoring
   - DO NOT add new test expectations during refactoring
6. **Repeat** for next feature/requirement

### Git Workflow

#### After Each Task Completion:
```bash
git add <files>
git commit -m "<commit-message>"
git push <options-for-MR>
```

#### Push Command Requirements:
- Use appropriate options to automatically open a Merge Request (MR)
- Include proper MR title and description in the push command

### Commit Message Standards

#### Structure:
```
<type>: <description>
[blank line]
<body explaining WHY the change was made>
```

#### Rules:
1. **Commit Title** (first line):
   - Format: `<type>: <description>`
   - Maximum 80 characters total
   - Types: `feat`, `fix`, `chore`, `ci`, `docs`, `test`
   - Example: `feat: add new bank accounts endpoint`

2. **Commit Body**:
   - Explain **WHY** the change was made, not WHAT
   - Focus on reasoning and context
   - Do not mention AI generation
   - Do not add yourself as author

#### Examples:
```
feat: add validation for email format

Added email validation to prevent invalid data from entering the system
and reduce support tickets related to account access issues.
```

```
fix: resolve race condition in payment processing

Multiple simultaneous requests were causing duplicate charges. Added
mutex lock to ensure atomic transaction processing.
```


## Additional Guidelines
- Always maintain clean, readable code
- Follow project-specific coding standards
- Ensure all tests pass before pushing
- Ensure the code builds before pushing
- If there's a linter, make sure there are no warnings before pushing
- Keep commits atomic and focused on single changes
