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

	if [[ "$is_compose" == true ]];then
		lang="compose"
	fi
	log "Creating project '$projectname' at $proj_dir"

	modulename="app"
	$is_library && modulename="library"

	quiet_mode=true
	add_module_for "$proj_dir"
	quiet_mode=false

	find "$proj_dir/" -type f -exec sed -i \
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
	local pkg="${packagename:-com.example.$(echo "${name,,}")}"
	local pkg_path="$(echo "$pkg" | sed 's#\.#/#g')"

	local settings_file="$(settings_file_for "$proj_dir")"
	if [[ -z "$settings_file" && -z "$projectname" ]]; then
		die "Current directory is not a Gradle project"
	elif [[ -z "$settings_file" ]]; then
		# Copy base project skeleton (with app/src/main/res + Manifest)
		cp -r "$template_root/base/project_level/"* "$proj_dir/"
		settings_file="$(settings_file_for "$proj_dir")"
	fi

	# Normalize module name (remove leading colon if present)
	modulename="${modulename#:}"

	# check if module already included
	if grep -Eq ":?$modulename" "$settings_file"; then
		die "Module: '$modulename' already exist"
		return 0
	fi


	echo "include(\":$modulename\")" >> "$settings_file"

	[[ -d "$proj_dir/$modulename" ]] && return 0

	# create module directory
	mkdir "$proj_dir/$modulename"

	cp -r "$template_root/base/module_level/"* "$proj_dir/$modulename/"

	local moduletype="app"
	if ! $is_library; then
		[[ -z "$activity" ]] && activity="MainActivity"
	else
		[[ -z "$activity" && -z "$classname" ]] && classname="MainClass"
		moduletype="library"
	fi

	# SDK defaults
	local minsdk="${min_sdk:-21}"
	local targetsdk="${target_sdk:-35}"


	mkdir -p "$proj_dir/$modulename/src/main/java"

	cp "$template_root/variants/$moduletype/AndroidManifest.xml" "$proj_dir/$modulename/src/main/"

	local build_file
	if [[ "$moduletype" == "app" ]]; then
		build_file="$template_root/variants/$moduletype/$lang/app/build.gradle"
	else
		build_file="$template_root/variants/$moduletype/$lang/build.gradle"
	fi
	
	# copy build.gradle file directy
	cp "$build_file" "$proj_dir/$modulename/"

	if $is_library; then
		# Remove all resource files
		for tmp_folder in `ls "$proj_dir/$modulename/src/main/res/"`; do
			rm -r "$proj_dir/$modulename/src/main/res/$tmp_folder/"*
		done
	fi

	# replace placeholders in all files
	find "$proj_dir/" -type f -exec sed -i \
		-e "s#__APP_NAME__#${appname}#g" \
		-e "s#__ACTIVITY_NAME__#${activity}#g" \
		-e "s#__MIN_SDK__#${minsdk}#g" \
		-e "s#__TARGET_SDK__#${targetsdk}#g" \
		-e "s#__PACKAGE_NAME__#${pkg}#g" \
		-e "s#__COMPILE_SDK__#${targetsdk}#g" {} +

	local auto_quite=true
	
	$quiet_mode	 && auto_quite=false || quiet_mode=true
	[[ -n "$activity" ]] && create_activity "$proj_dir"
	[[ -n "$classname" ]] && create_class "$proj_dir"
	$auto_quite && quiet_mode=false
	

	log "Added module: '$modulename' in $proj_dir"
}

