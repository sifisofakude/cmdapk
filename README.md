#cmdapk

[![License](https://img.sheilds.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

`cmdapk` is a lightweight CLI tool for scaffolding and building Android projects directly from the terminal

---

## Features
- Create new Android projects with a single command.
- Add new **Activities, Classes,Fragments, and Layouts** to an existing project
- Compile projects using Gradle.
- Install APKs directly onto a connected device device or emulator via `adb`.
- Supports **Bash (Linux/macOS)**.

---

## Requirements
Before using `cmdapk`, ensure you have the following installed and accessible in your environment:

- **Java JDK** (version compatible with your Android Gradle plugin).
- **Gradle**
- **Android SDK** (including platform-tools for `adb`)
- **Android NDK** (optional, only if you use C/C++ in your project)*
- `adb` must be available in your `PATH`.
	- Run `adb devices` to confirm it is set up correctly.

---

## Installation
1. Download or clone the repository:

```bash
git clone https://github.com/sifisofakude/cmdapk.git
cd cmdapk
```
     
2. Make the script executable (Linux/macOS):

```bash
chmod +x bin/cmdapk
```
3. Add the bin folder to your `PATH`
 
 Edit your shell profile (`~/.bashrc`,`~.zshrc`,etc):
 
```bash
 export PATH=/path/to/cmdapk/bin/:$PATH
```

## Configuration

Edit the settings file to configure project and SDK locations:

```bash
nano /path/to/cmdapk/etc/settings

#Root path for your Android projects
PROJECT_DIR=/path/to/my/projects

# Android SDK path
ANDROID_SDK=/path/to/Android/SDK

# Adnroid NDK path (if using C/C++)
ANDROID_NDK=/path/to/Android/NDK
```

## Usage
### Create a new project

```bash
# Bash 
cmdapk --new-project MyApp --package-name com.example.myapp

```

By default, all generated classes are created in **Java**.
Use `--lang kotlin` to generate Kotlin code instead.

### Compile a project

```bash
# Bash

# In current project
cmdapk --compile .

# From anywhere
cmdapk --compile MyApp
```

**Note**: Use `--compile` with `--module <name>` to compile a specific module in a multi-module project

### Install APK

```bash
# From current project
cmdapk --install .

# From anywhere
cmdapk --install MyApp
```

**Note on multiple devices**

If more than one device/emulator is connected, `adb install` will fail with:
```bash
error: more than one device/emulator
```

Run `adb devices` to list devices, then specify the target maunually

### Create new components inside a project

```bash
# Create a new activity.
cmdapk --activity LoginActivity [--package-name com.example.myapp --module <name>
--layout <name>]
# Create a new plain Java/Kotlin class 
cmdapk --class Utils [--packag-ename com.example.myapp]

# Create a new layout XML file
cmdapk --layout login_screen

```

## Command Otptions

Run `cmapk --help` for all options:

```bash
usage: cmdapk [options]

Options
    --new-project  <name>        Create a project with given name
    --package-name <name>        Specify package name
    --activity    <name>        Create a new Activity class  (or set main activity during project creation)
    --class       <name>        Create a new Java/Kotlin class (not an Activity)
    --layout      <name>        Create a new layout XML file (or set main layout during project creation)
    --minsdk      <version>     Minimum SDK version
    --maxsdk      <version>     Target SDK version
    --lang        <java/kotlin> Programming language (defaults to Java if not specified)
    --compile     <project>     Compile the specified project
    --install     <project>     Install APK for the specified project
```

## Quick Start Example
```bash
cmdapk --newproject HelloWorld --packagename com.example.helloworld
cd /path/to/my/projects/HelloWorld

cmdapk --compile .
cmdapk --insatll .

# Use Kotlin explicitly
cmdapk --activity LoginActivity --package-name com.example.helloworld --lang kotlin

# Add other components
cmdapk --class Utils --package-name com.example.helloworld
cmdapk --layout login_screen
```

## License

This project is liensed under the [Apache License 2.0](LICENSE)

## Contributing

Contributions are always welcome!

Please read the [CONTRIBUTING.md](CONTRIBUTING.md) for details on:

- Repository issues
- Submitting pull requests
- Coding style and documentation

---
