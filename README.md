# MarkdownScriptToolkit

This repository currently contains reusable Markdown lint helpers for the
Markdown files in this folder.

The repo is designed so you can:

- lint one or more Markdown files from Bash or PowerShell
- auto-fix the Markdown issues that `markdownlint` can repair
- install a `fixmd` command into your shell profile for reuse from any terminal
- enforce Markdown checks on staged files with a local git pre-commit hook
- run a self-test that proves the scripts are working after installation

## Files

- `scripts/fix-markdown.sh`: Bash wrapper around `markdownlint`
- `scripts/fix-markdown.ps1`: PowerShell wrapper around `markdownlint`
- `scripts/install-markdown-tools.sh`: adds `fixmd` to your Bash profile
- `scripts/install-markdown-tools.ps1`: adds `fixmd` to your PowerShell profile
- `scripts/install-git-hooks.sh`: configures the repo to use `.githooks`
- `scripts/install-git-hooks.ps1`: PowerShell version of git hook setup
- `scripts/test-markdown-tools.sh`: Bash self-test for lint and auto-fix flow
- `scripts/test-markdown-tools.ps1`: PowerShell self-test for lint and auto-fix flow
- `.githooks/pre-commit`: lints staged Markdown files during commit
- `.markdownlint.json`: repo lint configuration

## Prerequisite

Install `markdownlint` so both scripts can call it:

```bash
npm install -g markdownlint-cli
```

Git is also required if you want to use the local pre-commit hook.

## Run From This Repo

```bash
./scripts/fix-markdown.sh
./scripts/fix-markdown.sh --fix setupForSetExampleProject.md pullRequests.md
```

```powershell
./scripts/fix-markdown.ps1
./scripts/fix-markdown.ps1 -Fix setupForSetExampleProject.md pullRequests.md
```

If you do not pass any paths, the scripts lint every `.md` file under the repo
root.

## Install The Global Shell Commands

Run one installer for each shell you want to support.

### Git Bash installer

```bash
./scripts/install-markdown-tools.sh
```

Optional custom profile path:

```bash
./scripts/install-markdown-tools.sh --profile ~/.bash_profile
```

This appends a `fixmd` function to your Bash profile. After reloading the
profile, you can run:

```bash
fixmd
fixmd --fix README.md scripts/README.md
```

### PowerShell installer

```powershell
./scripts/install-markdown-tools.ps1
```

This appends a `fixmd` function to your PowerShell profile. After reloading the
profile, you can run:

```powershell
fixmd
fixmd -Fix README.md scripts/README.md
```

## Use From Any Git Bash Terminal

The standard approach is to add a shell function in `~/.bashrc` or
`~/.bash_profile`. This is more reliable than a Windows shortcut for CLI use.

Add this to `~/.bashrc`:

```bash
fixmd() {
  bash "/c/Users/Douglas/Documents/C#/GitHub/scripts/fix-markdown.sh" "$@"
}
```

Then reload your profile:

```bash
source ~/.bashrc
```

After that, from any Git Bash terminal:

```bash
fixmd
fixmd --fix /c/Users/Douglas/Documents/C#/GitHub/setupForSetExampleProject.md
```

If you prefer not to edit the profile manually, run:

```bash
./scripts/install-markdown-tools.sh
```

## Use From Any PowerShell Terminal

The standard approach is to add a function to your PowerShell profile. The
profile path is available in `$PROFILE`. A common location is:

```text
C:\Users\Douglas\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

Add this function to your profile:

```powershell
function fixmd {
    & "C:\Users\Douglas\Documents\C#\GitHub\scripts\fix-markdown.ps1" @args
}
```

Then reload your profile:

```powershell
. $PROFILE
```

After that, from any PowerShell terminal:

```powershell
fixmd
fixmd -Fix C:\Users\Douglas\Documents\C#\GitHub\setupForSetExampleProject.md
```

If you prefer not to edit the profile manually, run:

```powershell
./scripts/install-markdown-tools.ps1
```

## Install The Local Git Hook

The repository includes a pre-commit hook that lints only the staged `.md`
files in your commit.

Initialize git first if needed:

```bash
git init
```

Then install the hook path using either shell:

```bash
./scripts/install-git-hooks.sh
```

```powershell
./scripts/install-git-hooks.ps1
```

This sets `core.hooksPath` to `.githooks`, which is the standard Git-supported
way to version local hook scripts with the repository.

## Validate The Setup After Installation

Use the included self-test scripts to prove lint and auto-fix are working.

### Bash self-test

```bash
./scripts/test-markdown-tools.sh
```

### PowerShell self-test

```powershell
./scripts/test-markdown-tools.ps1
```

Each self-test creates a temporary Markdown file with fixable errors,
intentionally verifies that linting fails, runs the auto-fix flow, and then
verifies that the corrected file passes.

If you want a manual check instead, create a temporary Markdown file with
trailing spaces and extra blank lines, then run `fixmd` once without `--fix` or
`-Fix` and once again with it enabled.

## Alternative: Add `scripts` To `PATH`

If you prefer, you can add this repo's `scripts` folder to `PATH` in both shell
profiles. Profile functions are usually simpler because they let you call one
consistent command name in each shell without worrying about file extensions or
execution details.

If you add the folder to `PATH`, the direct commands are:

```bash
fix-markdown.sh README.md
test-markdown-tools.sh
```

```powershell
fix-markdown.ps1 README.md
test-markdown-tools.ps1
```

## Notes

- Git Bash and PowerShell use different argument styles, so separate wrappers
  are still the cleanest option.
- Windows `.lnk` shortcuts are not the normal way to expose CLI tools in either
  shell.
- If this repo moves, update the hard-coded path in your profile function.
- The installers avoid duplicate profile blocks by adding a marker section only
  once.
- The pre-commit hook checks staged Markdown files only, so unrelated files do
  not slow down commits.
