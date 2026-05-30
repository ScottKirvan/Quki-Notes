# Contributing to QuKi-Notes

First off, thank you for considering contributing to QuKi-Notes!

> **Note:** This is currently a personal project in early planning. External contributions aren't expected yet, but the design docs in `notes/dev/` are public — feel free to read along. Start with [`notes/dev/manifesto.md`](notes/dev/manifesto.md) to understand what QuKi-Notes is (and isn't).

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, include as many details as possible using our bug report template.

**Guidelines for bug reports:**
- Use a clear and descriptive title
- Describe the exact steps to reproduce the problem
- Provide specific examples to demonstrate the steps
- Describe the behavior you observed and what you expected to see
- Include screenshots if applicable
- Note your environment (OS, version, etc.)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, use our feature request template and include:

- A clear and descriptive title
- A detailed description of the proposed feature
- Examples of how the feature would be used
- Why this enhancement would be useful

### Pull Requests

**Before submitting a pull request:**

1. Fork the repository and create your branch from `main`
2. If you've added code, add tests if applicable
3. Ensure your code follows the existing style
4. Make sure your commits follow our commit message conventions
5. Update documentation as needed

**Commit Message Convention:**

We use [Conventional Commits](https://www.conventionalcommits.org/) with [Semantic Versioning](https://semver.org/):

- `feat:` - New features (bumps MINOR version)
- `fix:` - Bug fixes (bumps PATCH version)
- `feat!:` or `fix!:` - Breaking changes (bumps MAJOR version)
- `docs:` - Documentation only changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

**Examples:**
```
feat(editor): add formatting toolbar
fix(stream): preserve scroll position after swipe-to-delete
docs: clarify ephemerality model in manifesto
feat!: change transport plugin interface signature
```

See `notes/dev/pr_template.md` for the full PR title format and body template.

### Pull Request Process

1. Update the README.md with details of changes if applicable
2. Update the CHANGELOG.md is handled automatically by Release Please
3. The PR will be merged once you have approval from a maintainer
4. Your PR should pass all checks and have no merge conflicts

## Development Setup

See [`notes/dev/dev_env_setup.md`](notes/dev/dev_env_setup.md) for the full Windows 11 + Pixel 6 Pro + Linux setup walkthrough.

Once set up:

1. Fork and clone the repository
2. Create a feature branch (`feat/...`, `fix/...`, `chore/...`)
3. Make your changes; run `just lint` and `just test`
4. Submit a PR using `notes/dev/pr_template.md` for the body

## Project Structure

See [`notes/dev/design_spec.md`](notes/dev/design_spec.md) → Project Structure for the full layout.

## Testing

See [`notes/dev/testing.md`](notes/dev/testing.md). Tests ship with the code in every PR (ADR-13). Bug fixes follow the regression-test-first protocol.

## Questions?

Feel free to open an issue for questions or reach out via:
- [LinkedIn](https://www.linkedin.com/in/scottkirvan/)
- [Discord](https://discord.gg/TSKHvVFYxB)

Thank you for your contributions!
