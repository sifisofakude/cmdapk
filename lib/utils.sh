#!/usr/bin/env bash

#
# --------------------------------------------------------------------------------------
# 
# Copyright 2025 Sifiso Fakude
# 
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
# 
#       http://www.apache.org/licenses/LICENSE-2.0
# 
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# 
# --------------------------------------------------------------------------------------

# ------------------- Usage --------------------
usage()	{
cat <<EOF
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
    
EOF
}


# Utility: project path resolution
project_path_for()	{
	local proj="${1:-}"
	local candidate=""
	
	if [[ -z "$proj" || "$proj" == "." ]];then
		candidate="$(pwd)"
	elif [[ -d "$proj" ]];then
		# user gave an explicit path
		candidate="$(cd "$proj" && pwd)"
	elif [[ -n "${PROJECT_DIR:-}" && -d "$PROJECT_DIR/$proj" ]];then
		candidate="$(cd "$PROJECT_DIR/$proj" && pwd)"
	else
		die "Project $proj not found in current dir or PROJECT_DIR"
	fi
	
	printf '%s' "$candidate"
}

project_package_for()	{
	local proj_dir="${1:-$(current_project_root)}"
	local gradle_file=$(gradle_file_for "$proj_dir" "$modulename") || return 1

	# 1. Try namespace (modern AGP)
	local ns=$(grep -E '\s*namespace\s*' "$gradle_file" | head -n1 | sed -E "s/\s*namespace\s*=?\s*//;s/['|\"]//g")

	if [[ -n "$ns" ]]; then
		echo "$ns"
		return 0
	fi

	# 2. Try applicatinId (legacy style)
	local appId=$(grep -E '\s*applicatinId\s*' "$gradle_file" | head -n1 | sed -E "s/\s*applicationId\s*=?\s*//;s/['|\"]//g")
	if [[ -n "$appId" ]]; then
		echo "$appId"
		return 0
	fi

	# 3. Nothing found
	return 1
}

project_name_for()	{
	local proj_dir="${1:-$(current_project_root)}"

	# strip trailing slash if present, then basename
	proj_dir="${proj_dir%/}"

	basename "$proj_dir"
}


# Check if a file with the given basename exists, ignoring extension
# Usage: file_exists_ignore_ext "/path/to/dir/Foo"
# (will match Foo.java, Foo.kt, Foo.txt, etc)
file_exists_ignore_ext()	{
	local base="$1"

	# collect matches safely, suppress errors if none
	local matches
	matches="$(ls "${base}".* 2>/dev/null || true)"

	if [[ -n "$matches" ]]; then
		echo "$matches"
		return 0 # true: file(s) exist
	else
		return 1 # false: no matches
	fi
}

# Decide where to put source files(java/ vs kotlin/)
source_dir_for()	{
	local proj_dir="$1/$(echo "$modulename" | sed "s#:#/#g")/src/main"
	if [[ -d "$proj_dir/kotlin" ]]; then
		echo "$proj_dir/kotlin"
	else
		echo "$proj_dir/java"
	fi
}

gradle_file_for()	{
	local proj_dir="${1:-}" || die "No project directory supplied"
	
	local module 
	module="${2:-modulename}"
	module="$(echo "$module" | sed "s#:#/#g")"
	# echo $module

	[[ ! -d "$proj_dir/$module" ]] && die "No directory associated with module $module"

	if [[ -f "$proj_dir/$module/build.gradle" ]]; then
		echo "$proj_dir/$module/build.gradle"
		return 0
	elif [[ -f "$proj_dir/$module/build.gradle.kts" ]]; then
		echo "$proj_dir/$module/build.gradle.kts"
		return 0
	else
		echo ""
		return 1
	fi
}

settings_file_for()	{
	local proj_dir="${1}"

	if [[ -f "$proj_dir/settings.gradle" ]]; then
		echo "$proj_dir/settings.gradle"
		return 0
	elif [[ -f "$proj_dir/settings.gradle.kts" ]]; then
		echo "$proj_dir/settings.gradle.kts"
		return 0
	else
		echo ""
		return 1
	fi
}

current_project_root()	{
	local current_dir="${1:-.}"
	[[ "$current_dir" == "." || -z "$current_dir" ]] && current_dir="${PWD}"
	if [[ ! -d "$current_dir" && -d "$PROJECT_DIR/$current_dir" ]];then
		current_dir="$PROJECT_DIR/$current_dir"
	fi

	# Walk upward to find the root settings file
	while [[ "$current_dir" != "/" ]]; do
		if [[ -f "$current_dir/settings.gradle" || -f "$current_dir/settings.gradle.kts" ]]; then
			echo "$current_dir"
			return 0
		fi

		current_dir="$(dirname "$current_dir")"
	done
	
	echo ""
	return 1;
}

modules_for()	{
	local settings_file=""
	settings_file="$(settings_file_for "$1")" || die "No settings.gradle(.kts) found in '$1'"

	# Extract module names from include() lines
	grep -E "^include" "$settings_file" | \
		sed -E 's/include\s*\((.*)\)/\1/;s/include\s*//;s/://' | \
		tr -d "'" | tr -d '"' | tr ',' ' ' | tr '\n' ' ' | xargs
}

rename_namespace()	{
	project="$(project_name_for)"
	proj_dir="$(project_path_for)"

	if is_multi_module_project "$project" && [[ -z "modulename" ]];then
		die "Specify the module you want to apply the namespace to using --module <name>"
	fi

	# check if module/submodule directory exists incrementally
	local prevmodule=""
	local modules=($(echo "$modulename" | sed "s/:/\n/g"))

	for module in "${modules[@]}";do
		prevmodule="$prevmodule/$module"
		prevmodule="${prevmodule#/}"

		[[ ! -d "$prevmodule" ]] && echo "$(echo "$prevmodule" | sed "s#/#:#g")" && return 1
	done

	local build_file="$(gradle_file_for "$proj_dir" "$modulename")"
	if [[ -n "$build_file" ]];then
		sed -i -E "s/^[[:space:]]*namespace[[:space:]]*=?[[:space:]]\".*\"/namespace = \"$namespace\"/" "$build_file"
	fi
	
	return 0;
}

# current_project_root
