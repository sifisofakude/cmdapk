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

create_project()	{

	# project path
	local proj_dir="$PROJECT_DIR/$projectname"
	if [[ -d "$proj_dir" ]];then
		die "Project directory already exists: $proj_dir"
	else
		mkdir "$proj_dir"
	fi


	local composePlugin="/__COMPOSE_GRADLE_PLUGIN__/d"
	if [[ "$is_compose" == true ]];then
		language="compose"
		composePlugin="s/__COMPOSE_GRADLE_PLUGIN__/id/g"
	fi
	log "Creating project '$projectname' at $proj_dir"

	modulename="app"
	$is_library && modulename="library"

	local libraryPlugin="/__LIBRARY_GRADLE_PLUGIN__/d"
	local applicationPlugin="/__APPLICATION_GRADLE_PLUGIN__/d"

	if [[ "$modulename" == "app" ]];then
		applicationPlugin="s/__APPLICATION_GRADLE_PLUGIN__/id/g"
	else
		libraryPlugin="s/__LIBRARY_GRADLE_PLUGIN__/id/g"
	fi

	quiet_mode=true
	add_module_for "$proj_dir"
	quiet_mode=false

	find "$proj_dir/" -type f -exec sed -i \
		-e "$composePlugin" \
		-e "$applicationPlugin" \
		-e "$libraryPlugin" \
		-e "s#__PROJECT_NAME__#${projectname}#g" \
		-e "s#sdk.dir=#sdk.dir=${ANDROID_SDK:-}#g" \
		-e "s#ndk.dir=#ndk.dir=${ANDROID_NDK:-}#g" {} +
		
	log "Created Project: '$projectname' successfully"
}

add_module_for()	{
	# current_project_root() defined in utils.sh
	local proj_dir="${1:-$(current_project_root)}"
	local template_root="$TEMPLATE_ROOT/project"
	
	local appname="${appname:-$(project_name_for "$proj_dir")}"
	local activity="${activity}"
	local lang="${language,,}"
	local pkg="${packagename:-com.example.$(echo "${appname,,}")}"
	local pkg_path="$(echo "$pkg" | sed 's#\.#/#g')"

	[[ -z "$lang" ]] && lang="${LANG,,:-kotlin}"

	local dsl="${dsl:-$DSL_LANG}"
	[[ -z "$dsl" ]] && dsl="kotlin"

	local settings_file="$(settings_file_for "$proj_dir")"
	if [[ -z "$settings_file" && -z "$projectname" ]]; then
		die "Current directory is not a Gradle project"
	elif [[ -z "$settings_file" ]]; then
		# Copy base project skeleton (with app/src/main/res + Manifest)
		cp -r "$template_root/base/project_level/"* "$proj_dir/"

		if [[ "$dsl" == "kotlin" ]];then
			find "$proj_dir" -type f -name '*.gradle' ! -name '*.gradle.kts' | while read f;do \
				rm "$f" \
			;done
		else
			rm "$proj_dir/"*".gradle.kts"
		fi
		
		settings_file="$(settings_file_for "$proj_dir")"
	fi

	# Normalize module name (remove leading colon if present)
	modulename="${modulename#:}"

	# retrieve included modules
	local included_modules=$(grep -Eq "include" "$settings_file" | sed "s/include\s*//")
	
	# check if module is not already included
	if ! $(echo "$included_modules" | grep -Eq ":?$modulename"); then
		if [[ "$settings_file" == *".kts" ]];then
			echo "include(\":$modulename\")" >> "$settings_file"
		else
			echo "include \":$modulename\"" >> "$settings_file"
		fi
	fi

	[[ -d "$proj_dir/$(echo "$modulename" | sed "s#:#/#g")" ]] && return 0

	# check if module/submodule directory exists incrementally
	local i=0
	local prevmodule=""
	local modules=($(echo "$modulename" | sed "s/:/\n/g"))
	local module_len="${#modules[@]}"

	for module in "${modules[@]}";do
		prevmodule="$prevmodule/$module"
		prevmodule="${prevmodule#/}"

		[[ ! -d "$prevmodule" && $i -lt $module_len-1 ]] && die "Module '$(echo "$prevmodule" | sed "s#/#:#g")' does not exist in '$(project_name_for "$proj_dir")'"
		((i=$i+1))
	done

	# create module directory
	mkdir "$proj_dir/$(echo "$modulename" | sed "s#:#/#g")"

	cp -r "$template_root/base/module_level/"* "$proj_dir/$(echo "$modulename" | sed "s#:#/#g")"

	local moduletype="app"
	if ! $is_library; then
		[[ -z "$activity" ]] && activity="MainActivity"
	else
		[[ -z "$activity" && -z "$classname" ]] && classname="MainClass"
		moduletype="library"
	fi

	# SDK defaults
	local minsdk="${min_sdk:-$(echo "${MIN_SDK:-23}")}"
	local targetsdk="${target_sdk:-$(echo "${TARGET_SDK:-36}")}"
	local compilesdk="${compile_sdk:-$(echo "${COMPILE_SDK:-targetsdk}")}"


	mkdir -p "$proj_dir/$(echo "$modulename" | sed "s#:#/#g")/src/main/java"

	cp "$template_root/variants/$moduletype/AndroidManifest.xml" "$proj_dir/$(echo "$modulename" | sed "s#:#/#g")/src/main/"
	
	local build_file
	[[ "$dsl" == "kotlin" ]] && build_file="build.gradle.kts" || build_file="build.gradle"
	
	if [[ "$moduletype" == "app" ]]; then
		build_file="$template_root/variants/$moduletype/$lang/app/$build_file"
	else
		build_file="$template_root/variants/$moduletype/$lang/$build_file"
	fi

	# copy build.gradle file directy
	cp "$build_file" "$proj_dir/$(echo "$modulename" | sed "s#:#/#g")/"
	
	if $is_library; then
		# Remove all resource files
		for tmp_folder in `ls "$proj_dir/$(echo "$modulename" | sed "s#:#/#g")/src/main/res/"`; do
			rm -r "$proj_dir/$(echo "$modulename" | sed "s#:#/#g")/src/main/res/$tmp_folder/"*
		done
	fi

	[[ -z "$namespace" ]] && namespace="$pkg"
	# replace placeholders in all files
	find "$proj_dir/" -type f -exec sed -i \
		-e "s#__APP_NAME__#${appname}#g" \
		-e "s#__ACTIVITY_NAME__#${activity}#g" \
		-e "s#__MIN_SDK__#${minsdk}#g" \
		-e "s#__TARGET_SDK__#${targetsdk}#g" \
		-e "s#__COMPILE_SDK__#${compilesdk}#g" \
		-e "s#__PACKAGE_NAME__#${pkg}#g" \
		-e "s#__NAMESPACE__#${namespace}#g" \
		-e "s#__COMPILE_SDK__#${targetsdk}#g" {} +

	local auto_quite=true
	
	$quiet_mode	 && auto_quite=false || quiet_mode=true
	[[ -n "$activity" ]] && create_activity "$proj_dir"
	[[ -n "$classname" ]] && create_class "$proj_dir"
	$auto_quite && quiet_mode=false
	

	log "Added module: '$modulename' in $proj_dir"
}

