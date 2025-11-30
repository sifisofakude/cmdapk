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
- [sdkmanager](https://developer.android.com/studio#command-line-tools-only) must be available in your `PATH` to be able to download Android SDK/NDK automatically.

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

# Default programming language for classes
LANG="kotlin"

# Android minimum SDK version
MIN_SDK=23

# Android target SDK version
TARGET_SDK=36

# Android compile SDK version
COMPILE_SDK=36

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

```
Usage: cmdapk [options]

 Scaffolding:
     # Create a new project
     cmdapk --newp-roject MyApp [ --package-name com.example.myapp --activity SplashScreenActivity 
            --layout activity_splash --lang kotlin --compose ]

     # Add Activity to current project, specify a module if it's a mutli-module project
     cmdapk --activity LoginActivity [ --package-name com.example.myapp --lang kotlin --module <name> --compose ]

     # Add plain class to current project
     cmdapk --class MyClass [ --package-name com.example.myclass --lang kotlin --module <name> ]

     # Add layout to current project (must not be a Jetpack Compose project)
     cmdapk --layout tutorial_screen [ --qualifier land|sw600dp|etc  ]

 Build/Install:
     # Build release/debug apk
     cmdapk --compile MyApp [ --release --no-install --aab ]
     
     # Install debug/release apk
     cmdapk --install MyApp [ --release ]
     
 Options:
    --new-project     <name>         Create a new project in PROJECT_DIR, initial module is of type application 
                                     unless --library is passed
                                     
    --package-name    <name>         Package name for project or scaffolding
    
    --add-module      <name>         Add a module to current project
    
    --namespace       <name>         Set/rename namespace for current project
    
    --app-name        <name>         Use when creating an application module, ignored when --library is passed
    
    --activity        <name>         Create an Activity (or set main Activity during project creation)
    
    --class           <name>         Add a plain Java/Kotlin class to an existing project
    
    --layout          <name>         Create a layout xml file (or set main Layout during project creation)
    
    --qualifier       <qual>         Layout qualifier (land, sw600dp, v21, etc)
    
    --compose                        Create a JetPack Compose project or activity
    
    --compile         [<project>]    Compile a specified project (defaults to current dir if ".")
    
    --no-install                     Use with --compile to prevent auto-installation after compilation
    
    --module          <name>         A module to perfom an action to
    
    --aab                            Use with --compile to bundle an AAB file instead of APK
    
    --install         [<project>]    Install app for the specified project (defaults to current dir if ".")
    
    --release                        Use with --compile to build a Release APK, or --install to install a Release APK.
    
    --library                        Use with --new-project or --add-module to specify a module will be an Android library.
    
    --lang            <java|kotlin>  Language for generated classes (defaults to java or kotlin if its a Jetpack Compose project)
    
    --minsdk          <value>        Minimum SDK version
    
    --targetsdk       <value>        Target SDK version
    
    --help                           Show this help and exit
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
