# MarkdownScriptToolkit Scripts

These wrappers reuse the repo Markdown lint setup in [..\/.markdownlint.json](../.markdownlint.json).

## Main Commands

```bash
./scripts/fix-markdown.sh
./scripts/fix-markdown.sh MarkdownDocs/setupForSetExampleProject.md MarkdownDocs/pullRequests.md
./scripts/fix-markdown.sh --fix .
```

## PowerShell

```powershell
./scripts/fix-markdown.ps1
./scripts/fix-markdown.ps1 MarkdownDocs/setupForSetExampleProject.md MarkdownDocs/pullRequests.md
./scripts/fix-markdown.ps1 -Fix .
```

If you do not pass any paths, the scripts lint every `.md` file under the repo root.
You can pass one or more files or directories.

## Install Helpers

```bash
./scripts/install-markdown-tools.sh
./scripts/install-git-hooks.sh
```

```powershell
./scripts/install-markdown-tools.ps1
./scripts/install-git-hooks.ps1
```

## Self-Test

```bash
./scripts/test-markdown-tools.sh
```

```powershell
./scripts/test-markdown-tools.ps1
```

The self-test creates a temporary Markdown file with fixable lint errors,
verifies that linting fails first, runs the auto-fix flow, and then verifies
that the file passes.
