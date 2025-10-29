# Contributing to cmdapk

Thanks for your interest in contributing to **cmdapk**!
This project is meant to make Android app development easier from the command-line, and contributions are always welcome.

---

## How to Contribute

### 1. Reporting Issues
- Use the **Issues** tab to report bugs, request features, or suggest improvements.
- Please provide clear steps to reproduce bugs and, if possible, share error logs or screenshots.

### 2. Submitting Changes
1\. **Fork** the repository

2\. **Clone** your fork locally
```bash
git clone https://github.com/sifisofakude/cmdapk.git
cd cmdapk
```
3\. Create a **new branch** for your work:
```bash
git checkout -b feature/my-feature
```

4\. Make your changes (see coding style below).

5\. Commit with a clear message:
```bash
git commit -m "Added support for --device option"
```
6\. Push to your work:
```bash
git push origin feature/my-feature
```
7\. Open a **Pull Request**(PR) to the `main` branch of this repository.

## Coding Style
- Use **Bash best practices** (for shell scripts) - Keep scripts POSIX-compatible where possible.
- Keep code **readable and commented** - explain non-obvious logic.
- Follow existing **naming conventions** for options (`--long-option`  style).
- Use **Java by default** for generated classes unless `--lang kotlin` is explicitly passed.

## Tests

Right now `cmdapk` does not have automated tests.

- Please **manually test** your changes (project creation, compiling, installing).
- Share tested commands in your Pull Request description.

## Community

- Be respectful and constructive in discussions