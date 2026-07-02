# Tool Efficiency Protocol

**Every skill MUST follow these tool usage rules to minimize token consumption and maximize speed.**

## Rule 1: Parallel Tool Calls

When multiple inputs are independent, issue ALL reads/globs/greps in a single message. Never read files one by one when they can be read simultaneously.

**WRONG:**
```
Read("file1.md")
# wait for result
Read("file2.md")
# wait for result
Read("file3.md")
```

**RIGHT:**
```
# All three in one message:
Read("file1.md")
Read("file2.md")
Read("file3.md")
```

## Rule 2: Use Discovery Tools Before Full Reads

For code analysis, use `Glob` and `Grep` to map structure and find symbols before reading full files. Only use full `Read` for specific files you need to inspect in detail.

| Need | Tool | Token Cost |
|------|------|-----------|
| File structure overview | `Glob("path/**/*.ext")` | Low (~200-500 tokens) |
| Find a symbol or pattern | `Grep(pattern, path)` | Low (~200-800 tokens) |
| Full file content | `Read(file)` | High (~500-5000 tokens) |
| Find symbols across codebase | `Grep(query)` | Low (~300-800 tokens) |

## Rule 3: Use the Right Tool for the Job

| Task | Use This | NOT This |
|------|----------|----------|
| Find files by name/pattern | `Glob` | `find` via Bash |
| Search file contents | `Grep` | `grep`/`rg` via Bash |
| Read a file | `Read` | `cat`/`head`/`tail` via Bash |
| Modify existing file | `Edit` | `sed`/`awk` via Bash |
| Create new file | `Write` | `echo`/heredoc via Bash |
| Run system commands | `Bash` | — |

## Rule 4: Batch Operations

When creating multiple files, use parallel Write/Edit calls where possible. When reading a directory of related files, use Glob first to discover files, then parallel Read.

## Rule 5: Config-Aware Paths

Always check `.production-grade.yaml` for path overrides before using hardcoded paths. This allows the plugin to work with existing project structures.

```
# Read config paths
config = Read(".production-grade.yaml")
api_path = config.paths.api_contracts || "api/openapi/*.yaml"
arch_path = config.paths.architecture_docs || "docs/architecture/"
```
