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

compile_project()	{
	# resolve project path
	local proj_dir="$(current_project_root "$compile_target")"
	local projectname="$(project_name_for "$proj_dir")"

	if ! is_multi_module_project "$proj_dir" && [[ -z "$modulename" ]]; then
		modulename="$(modules_for "$proj_dir")"
	elif [[ -n "$modulename" && ! -d "$proj_dir/$(echo "$modulename" | sed "s#:#/#g")" ]]; then
		die "Module '$modulename' does not exist. Run cmdapk --add-module $modulename to create it."
	fi

	
	local modules="$(modules_for "$proj_dir")"
	
	local module="${modulename:-}"
	if [[ -z "$module" ]] && is_multi_module_project "$proj_dir"; then
		# Search for the first encounter of *app* module
		for tmpModule in "${modules[@]}";do
			if [[ ! -z "$(echo "$tmpModule" | grep "[Aa]pp")" ]]; then
				modulename="$tmpModule"
				break
			fi
		done
	fi

	# determine build type from global
	local task_prefix build_type
	if [[ "$bundle_aab" == true ]]; then
		task_prefix="bundle"
		build_type="Release"
	else
		task_prefix="assemble"
		[[ "$is_release" == true ]] && build_type="Release" || build_type="Debug"
	fi
	if [[ ! -z "$modulename" && ! -d "$proj_dir/$(echo "$modulename" | sed "s#:#/#g")" ]]; then
		die "Module '$modulename' does not exist"
	fi

	local log_msg="$($bundle_aab && echo "Bundling" || echo "Assembling") a ${build_type,,} $($bundle_aab && echo "AAB" || echo "APK") for module '$module' in project '$(project_name_for "$proj_dir")'"

	local gradle_file=""
	[[ ! -z "$modulename" ]] &&	gradle_file="$(gradle_file_for "$proj_dir" "$modulename")"
	
	local type=""
	# retrieve the type of the module(android application/library java application/library)
	[[ ! -z "$gradle_file" ]] && type="$(module_type "$gradle_file")"

	if [[ "$type" == "com.android.library" ]]; then
		task_prefix="assemble"
		log_msg="Assembling a ${build_type,,} AAR for module '$module' in project '$(project_name_for "$proj_dir")'"
	elif [[ "$type" == "application" || "$type" == "java"* || -z "$type" || -z "$module" ]]; then
		build_type=""
		task_prefix="build"
		log_msg="Building project '$(project_name_for "$proj_dir")'"

		no_install=true
	fi
	# actual gradle tesk to execute
	gradle_task="${task_prefix}${build_type}"
	[[ -n "$module" ]] && gradle_task=":${module}:${gradle_task}"

	# choose gradle command
	local gradle_cmd
	if [[ -x "$proj_dir/gradlew" ]];then
		gradle_cmd="./gradlew"
	elif command -v gradle >/dev/null 2>&1; then
		gradle_cmd="gradle"
	else
		die "Neither ./gradlew nor system 'gradle' found. Please install Gradle or include a wrapper"
	fi

	log "$log_msg ..."
	(cd "$proj_dir" && $gradle_cmd "${gradle_task}") || \
		die "Gradle build failed."
	# [[ ! $no_install && ! $bundle_aab ]] && install_apk $proj_dir
	if ! $no_install && ! $bundle_aab; then
		install_target="$proj_dir"
		install_apk
	fi
}

install_apk()	{
	local project="${install_target:-$(current_project_root ".")}"

	# resolve project path
	local proj_dir="$(project_path_for "$project")" || die "Project '$project' not found"

	# check adb availability
	if ! command -v adb >/dev/null 2>&1; then
		die "adb not found. Please install Android platform-tools and add it to PATH"
	fi

	# check connected deviced
	if ! adb get-state >/dev/null 2>&1; then
		die "No Android device or emulator detected. Start one and try again."
	fi

	# determine build type from global
	local build_type="debug"
	$is_release && build_type="release"

	local modules="$(modules_for "$proj_dir")"
	
	local module="${modulename:-}"
	
	if [[ -z "$module" ]] && is_multi_module_project "$proj_dir"; then
		# IFS=' '
		# echo "${modules[*]}" | grep -o '\S*\s*'
		module=("$(echo "${modules[*]}" | grep -o '\S*[Aa]pp\S*' | tr '\n' ' ' | sed "s/\s$//")")

		IFS=' ' read -r -a modules <<< "$module"

		if (( ${#modules[@]} > 1 )); then
			die "'$projectname' is a multi-module project.use --compile with --module <name>"
			return 0;
		fi
	elif [[ -z "$module" ]] && ! is_multi_module_project "$proj_dir"; then
		module="${modules[0]}"
	fi

	# expected APK output dir
	local apk_dir="$proj_dir/$(echo "$module" | sed "s#:#/#g")/build/outputs/apk/$build_type"
	[[ ! -d "$apk_dir" ]] && die "APK directory not found: $apk_dir/. Please biuld the project first"
	
	# look for and existing APK
	local apk="$(find "$apk_dir" -name "*.apk" | head -n 1)"

	if [[ -z "$apk" ]];then
		if $strict_mode; then
			die "No APK found in $apk_dir. Please run cmdapk --compile $project first"
		else
			# Might not be an Android project, exit with success
			exit 0
		fi
	fi

	log "Installing $apk ..."
	adb install -r $apk || die "adb install failed"
	log "Installed $apk successfully"
}
		
