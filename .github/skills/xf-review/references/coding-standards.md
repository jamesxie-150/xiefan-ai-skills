# Team Coding Standards

## Python
- Use type hints for all function arguments and return values.
- Follow PEP 8 strictly.
- Docstrings must be Google style.
- Use `with` statement for all resource management (files, locks, connections).
- Prefer f-strings over string concatenation or `.format()`.
- Use `None` as default for mutable arguments, initialize inside function body.

## TypeScript / JavaScript
- Use strict mode (`"strict": true` in tsconfig).
- Prefer `const` over `let`; never use `var`.
- Use async/await over raw Promises where possible.
- Handle all Promise rejections.

## General
- Functions should have a single responsibility.
- Cyclomatic complexity should not exceed 10.
- Magic numbers must be named constants.
- All public APIs must have documentation.

## Security
- Never hardcode API keys, passwords, or secrets. Use environment variables.
- Validate and sanitize all user inputs.
- Use parameterized queries for database operations (no string interpolation).
- Avoid `eval()`, `exec()`, and similar dynamic code execution.
- Use `except SpecificException` instead of bare `except:`.

## Error Handling
- Always catch specific exceptions, not generic ones.
- Log errors with sufficient context for debugging.
- Clean up resources in `finally` blocks or use context managers.
