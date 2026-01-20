# Security Policy

## 🔒 Supported Versions

We actively support the following versions with security updates:

| Version | Supported          | Status |
|---------|--------------------|--------|
| 1.1.x   | ✅ Yes             | Active |
| 1.0.x   | ⚠️ Limited         | EOL soon |
| < 1.0   | ❌ No              | Unsupported |

**Recommendation**: Always use the latest stable release from the [Releases page](https://github.com/fidpa/bash-markdown-link-validator/releases).

---

## 🐛 Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security issue, please follow responsible disclosure:

### 📧 Contact

**DO NOT** open a public GitHub issue for security vulnerabilities.

Instead, report via:

1. **GitHub Security Advisories** (Preferred):
   - Go to [Security → Advisories](https://github.com/fidpa/bash-markdown-link-validator/security/advisories)
   - Click "Report a vulnerability"
   - Provide details using the template below

2. **Email** (Alternative):
   - Contact: [your-email@example.com]
   - Subject: `[SECURITY] bash-markdown-link-validator vulnerability`
   - Use PGP key (if available): [link to PGP key]

### 📋 Report Template

```markdown
## Vulnerability Description
[Clear description of the security issue]

## Impact
[Potential impact: data exposure, code execution, etc.]

## Steps to Reproduce
1. Step 1
2. Step 2
3. ...

## Proof of Concept
[Code snippet, logs, or screenshots]

## Suggested Fix
[Optional: Your recommendation for fixing the issue]

## Environment
- Version: [e.g., v1.1.0]
- OS: [e.g., Ubuntu 22.04]
- Bash Version: [output of `bash --version`]
```

---

## ⏱️ Response Timeline

| Stage | Timeline | Description |
|-------|----------|-------------|
| **Acknowledgment** | 48 hours | We confirm receipt of your report |
| **Initial Assessment** | 7 days | We evaluate severity and impact |
| **Fix Development** | 14-30 days | We develop and test the fix |
| **Disclosure** | 30-90 days | Coordinated public disclosure |

**Note**: Timelines may vary based on complexity and severity.

---

## 🛡️ Security Best Practices

### For Users

1. **Keep Updated**: Use the latest stable release
2. **Review Code**: Inspect scripts before running in sensitive environments
3. **Least Privilege**: Run with minimal necessary permissions
4. **Input Validation**: Be cautious with untrusted Markdown files

### For Contributors

1. **No Secrets**: Never commit credentials, tokens, or sensitive data
2. **ShellCheck**: Run `shellcheck` to catch common vulnerabilities
3. **Input Sanitization**: Always validate and sanitize user inputs
4. **Dependency Security**: Minimize dependencies (we have zero!)

---

## 🔍 Known Security Considerations

### 1. File System Access

- **Risk**: Scripts read files from the file system
- **Mitigation**: Run in controlled environments, use `--exclude` for sensitive dirs

### 2. External Links

- **Risk**: Validates HTTP(S) links (no actual HTTP requests by default)
- **Mitigation**: JSON mode for CI/CD, avoid executing external code

### 3. Bash Execution

- **Risk**: Shell injection if inputs are not sanitized
- **Mitigation**: All variables are quoted, no `eval` usage

---

## 📜 Security Audit History

| Date | Version | Type | Summary |
|------|---------|------|---------|
| 2025-01 | v1.1.0 | Internal Review | No vulnerabilities found |
| 2024-12 | v1.0.0 | Initial Release | Baseline security assessment |

---

## 🏆 Acknowledgments

We appreciate security researchers who help improve this project:

<!-- Example:
- **[Researcher Name]** - [Vulnerability Type] (2025-01)
-->

*No security reports yet. Be the first!*

---

## 📞 Questions?

For general security questions (not vulnerabilities):

- **Discussions**: [GitHub Discussions](https://github.com/fidpa/bash-markdown-link-validator/discussions)
- **Documentation**: [CONTRIBUTING.md](CONTRIBUTING.md)

---

**Thank you for helping keep bash-markdown-link-validator secure!** 🔐
