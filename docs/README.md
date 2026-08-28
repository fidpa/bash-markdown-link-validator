# Documentation Index

**Welcome to the bash-markdown-link-validator documentation!**

This directory contains detailed documentation for installation, usage, and troubleshooting.

---

## 📚 Quick Navigation

| Document | Purpose | When to Read |
|----------|---------|--------------|
| **[QUICK_START.md](QUICK_START.md)** | Installation & First Steps | 🟢 **Start Here** |
| **[WRAPPER_SYSTEM.md](WRAPPER_SYSTEM.md)** | Multi-Area Patterns | Advanced Usage |
| **[API_REFERENCE.md](API_REFERENCE.md)** | Function Details | Development |
| **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** | Problem Solutions | When Stuck |

---

## 🎯 Documentation by Use Case

### Getting Started
- **New User?** → [QUICK_START.md](QUICK_START.md)
- **Complex Project?** → [WRAPPER_SYSTEM.md](WRAPPER_SYSTEM.md)

### Development
- **Building Integrations?** → [API_REFERENCE.md](API_REFERENCE.md)
- **Custom Wrappers?** → [WRAPPER_SYSTEM.md](WRAPPER_SYSTEM.md)

### Troubleshooting
- **Links not Found?** → [TROUBLESHOOTING.md](TROUBLESHOOTING.md) § Anchor Resolution
- **Performance Issues?** → [TROUBLESHOOTING.md](TROUBLESHOOTING.md) § Parallel Processing
- **False Positives?** → [TROUBLESHOOTING.md](TROUBLESHOOTING.md) § Exclusion Patterns

---

## 📖 Document Summaries

### QUICK_START.md
**Length**: 179 lines | **Difficulty**: Beginner

- Installation methods
- Basic usage examples
- Simple wrapper script
- First validation run

### WRAPPER_SYSTEM.md
**Length**: 338 lines | **Difficulty**: Intermediate

- Multi-area validation patterns
- DRY principle implementation
- Advanced wrapper configurations
- Production examples (11 active deployments)

### API_REFERENCE.md
**Length**: 593 lines | **Difficulty**: Advanced

- Function signatures
- Configuration variables
- Return codes and error handling
- Integration patterns

### TROUBLESHOOTING.md
**Length**: 315 lines | **Difficulty**: All Levels

- Common issues and solutions
- Anchor resolution edge cases
- Performance optimization
- Debugging techniques

---

## 🔗 External Resources

### Community
- **Main README**: [../README.md](../README.md)
- **Contributing**: [../CONTRIBUTING.md](../CONTRIBUTING.md)
- **Code of Conduct**: [../CODE_OF_CONDUCT.md](../CODE_OF_CONDUCT.md)
- **Security Policy**: [../SECURITY.md](../SECURITY.md)

### Repository
- **GitHub**: [fidpa/bash-markdown-link-validator](https://github.com/fidpa/bash-markdown-link-validator)
- **Issues**: [Report a bug](https://github.com/fidpa/bash-markdown-link-validator/issues)
- **Discussions**: [Ask questions](https://github.com/fidpa/bash-markdown-link-validator/discussions)

---

## 💡 Quick Tips

### For New Users
```bash
# 1. Clone the repository
git clone https://github.com/fidpa/bash-markdown-link-validator.git

# 2. Read QUICK_START.md
cat docs/QUICK_START.md

# 3. Create your first wrapper
./examples/validate-docs-wrapper.sh
```

### For Advanced Users
- **Wrapper System**: See [WRAPPER_SYSTEM.md](WRAPPER_SYSTEM.md) for DRY patterns
- **CI/CD Integration**: Use `--output-format=json` for machine-readable output
- **Performance**: Adjust `PARALLEL_JOBS` in wrapper scripts

### For Developers
- **API Reference**: See [API_REFERENCE.md](API_REFERENCE.md) for function details
- **Contributing**: Read [../CONTRIBUTING.md](../CONTRIBUTING.md) before submitting PRs
- **Testing**: There is no test suite. Run a wrapper over your own documentation, and see [CONTRIBUTING.md](../CONTRIBUTING.md) for the checks a change has to pass

---

## 📊 Documentation Statistics

| Metric | Value |
|--------|-------|
| **Total Documents** | 4 |
| **Total Lines** | 1425 |
| **Average Read Time** | 5-10 minutes each |
| **Last Updated** | 2026-08-28 |

---

## 🆘 Need Help?

1. **Check FAQ**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. **Search Issues**: [GitHub Issues](https://github.com/fidpa/bash-markdown-link-validator/issues)
3. **Ask Community**: [GitHub Discussions](https://github.com/fidpa/bash-markdown-link-validator/discussions)
4. **Read Examples**: [../examples/](../examples/)

---

**Happy validating!** 🚀
