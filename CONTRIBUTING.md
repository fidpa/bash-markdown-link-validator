# Contributing to bash-markdown-link-validator

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Development Setup](#development-setup)
- [Code Style](#code-style)
- [Commit Message Format](#commit-message-format)
- [Pull Request Process](#pull-request-process)
- [Testing](#testing)

---

## 📜 Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

---

## 🔧 Development Setup

### Prerequisites

- Bash 4.0+
- Git
- ShellCheck (recommended)

### Setup Steps

```bash
# Clone the repository
git clone https://github.com/fidpa/bash-markdown-link-validator.git
cd bash-markdown-link-validator

# Test locally
./validate-docs-wrapper.sh
```

### Running Tests

```bash
# Validate test fixtures
cd test/
bash ../src/validate-markdown-links.sh test-docs/

# Expected: 0 broken links
```

---

## 🎨 Code Style

### Bash Best Practices

1. **Error Handling**: Use `set -uo pipefail` at the top of scripts
2. **Quoting**: Always quote variables: `"$variable"`
3. **Functions**: Use snake_case for function names
4. **Comments**: Add comments for complex logic
5. **Exit Codes**: Use meaningful exit codes (0 = success, 1+ = errors)

### ShellCheck Compliance

All scripts must pass ShellCheck validation:

```bash
shellcheck src/*.sh examples/*.sh install.sh
```

### Code Formatting

- **Indentation**: 4 spaces (no tabs)
- **Line Length**: Max 120 characters
- **Braces**: Use `{...}` for all variables: `"${var}"`

---

## 📝 Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding/updating tests
- `chore`: Maintenance tasks

### Examples

```
feat(validator): add support for relative anchor links

- Implement suffix-matching for anchor resolution
- Add test cases for edge cases
- Update documentation

Closes #42
```

```
fix(parser): handle markdown tables with pipes

Previously failed on tables with inline code containing pipes.
Now properly escapes pipe characters in code blocks.

Fixes #38
```

---

## 🔄 Pull Request Process

### Before Submitting

1. **Test locally**: Run `./validate-docs-wrapper.sh` on your changes
2. **ShellCheck**: Ensure all scripts pass `shellcheck`
3. **Update docs**: Add/update documentation if needed
4. **CHANGELOG**: Add entry to `CHANGELOG.md` under `[Unreleased]`

### Submitting a PR

1. **Fork** the repository
2. **Create a branch**: `git checkout -b feature/your-feature-name`
3. **Commit changes**: Follow commit message format
4. **Push**: `git push origin feature/your-feature-name`
5. **Open PR**: Use the PR template (if available)

### PR Description Template

```markdown
## Description
[Brief description of changes]

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tested locally with test fixtures
- [ ] ShellCheck passes
- [ ] No regressions on existing test cases

## Related Issues
Closes #[issue number]
```

### Review Process

- PRs require at least one approval
- CI checks must pass (when configured)
- Address review comments promptly
- Squash commits before merging (if requested)

---

## 🧪 Testing

### Manual Testing

```bash
# Test on sample docs
./validate-docs-wrapper.sh

# Test with specific exclusions
EXCLUDE_DIRS="archive|deprecated" ./validate-docs-wrapper.sh

# Test JSON output
./src/validate-markdown-links.sh docs/ --json
```

### Test Checklist

- [ ] Validates correct links without errors
- [ ] Detects broken links correctly
- [ ] Handles edge cases (spaces, umlauts, special chars)
- [ ] Anchor resolution works (suffix-match)
- [ ] JSON output is valid
- [ ] Wrapper system functions correctly

---

## 🐛 Reporting Issues

### Before Reporting

1. **Search existing issues**: Check if already reported
2. **Test latest version**: Update to latest release
3. **Minimal reproduction**: Provide minimal test case

### Issue Template

```markdown
## Description
[Clear description of the issue]

## Steps to Reproduce
1. Step 1
2. Step 2
3. ...

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Environment
- OS: [e.g., Ubuntu 22.04, macOS 13]
- Bash Version: [output of `bash --version`]
- Tool Version: [output of `git describe --tags`]

## Additional Context
[Logs, screenshots, config files]
```

---

## 💡 Questions?

- **Documentation**: Check [docs/](docs/)
- **Discussions**: Use GitHub Discussions
- **Security**: See [SECURITY.md](SECURITY.md)

---

**Thank you for contributing!** 🎉
