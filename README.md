#cmdapk

A script to help create and compile android applications using `gradle` and android gradle plugin.

## Configuration

After downloading repo, extract contents to the directory you wish to 
access the scripts from, change to path/to/cmdapk-master or `cd cmdapk-master` 
from the directory you cloned the repo to.

### Linux

```bash
###Linux

# Add execution permission
chmod +x bin/cmdapk

# Add the bin folder to PATH
# Find out which file your machine keep enviroment variable and add
PATH=/path/to/cmdapk-master/bin:$PATH
```

```bash
###Linux

# For PowerShell if the above does not work
nano ~/.config/powershell/Microsoft.PowerShell_profile.ps1

# Add line
$env:PATH="/path/to/cmdapk-master/bin:" + $env:PATH
```

### Windows
1. Press `Win + S`, type "***Environment Variables***", and select 
"***Edit the system environment variables***"
2. In the System Properties window, click the 
"***Environment Variables...***" button
3. Under "***System variables***" or "***User Variables***", 
scroll and select the `Path` variable, the click "***Edit...***".
4. Click "***New***" and add full path to the folder you want in this 
case `drive:\path\to\cmdapk-master\bin` (eg., `C:\path\to\cmdapk-master\bin` 
5. Click ***Ok*** on all windows to apply the changes

#### Setting script environment variables
```bash
### Bash
nano /path/to/cmdapk-master/etc/settings

# Set PROJECT_DIR. this variable set the root path
# where your projects will be created
PROJECT_DIR=/path/to/my/projects

# Set ANDROID_SDK. this variable set the root path
# of the SDK software
ANDROID_SDK=/path/to/Android/SDK

# Set ANDROID_NDK. this variable set the root path
# for the NDK if you're going to be using C/C++
ANDROID_NDK=/path/to/Andriod/NDK


### PowerShell
nano /path/to/cmdapk-master/etc/settings.ps1

# Set PROJECT_DIR. this variable set the root path
# where your projects will be created
$PROJECT_DIR=\path\to\my\projects

# Set ANDROID_SDK. this variable set the root path
# of the SDK software
$ANDROID_SDK=\path\to\Android\SDK

# Set ANDROID_NDK. this variable set the root path
# for the NDK if you're going to be using C/C++
$ANDROID_NDK=\path\to\Andriod\NDK
```

## Usage
```bash
###Bash

# Create a new project
cmdapk --projectname NewProject --packagename com.example.app

## Compile project

# Compile project in current project
cmdapk --compile .

# Compile project from anywhere
cmdapk --compile Project

## Install app

# Install app from current project
cmdapk --install .

# Install app from anywhere
cmdapk --compile Project



###PowerShell

# Create a new project
cmdapk --projectname ProjectName --packagename com.example.app

## Compile project

# Compile project in current project
cmdapk --compile .

# Compile project from anywhere
cmdapk --compile ProjectName

## Install app

# Install app from current project
cmdapk --install .

# Install app from anywhere
cmdapk --compile ProjectName
```
#### Command options

```
cmdapk --help

usage:
cmdapk --project-name param 
  options:
     --projectname param      create a project with name
     --packagename param      package name
     --activity    param      main activity class
     --layout      param      main layout
     --minsdk      param      minimum sdk version the application
                              will be compatable with
     --maxsdk      param      targeted sdk version the application
                              will be compatable with
    --lang         param      specify a language to write the application
                              with(java/kotlin)
    --compile      param      compile provided project
    --install      param      install app for provided project
```