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

create_layout()	{
	local proj_dir="${1:-$(current_project_root "$action_projectname")}"
	[[ -z "$proj_dir" ]] && exit

	[[ -z "$layoutname" ]] && die "Layout name required (use --layout <name>)"

	if ! is_multi_module_project "$proj_dir" && [[ -z "$modulename" ]]; then
		modulename="$(modules_for "$proj_dir")"
	elif [[ -n "$modulename" && ! -d "$proj_dir/$(echo "$modulename" | sed "s#:#/#g")" ]]; then
		die "Module '$modulename' does not exist. Run cmdapk --add-module $modulename to create it."
	elif [[ -z "$modulename" ]]; then
		die "Module is required to create a layout in a mitli module project. Run cmdapk --module <name> --layout <name>"
	fi

	# optional qualifier
	local qualifier=""
	if [[ -n "$layout_qualifier" ]]; then
		case "$layout_qualifier" in
			land|port|sw[0-9]*dp|w[0-9]*dp|h[0-9]*dp|small|normal|large|xlarge|night|notnight|v[0-9]*)
				qualifier="-$layout_qualifier"
				;;
			*) die "Invalid layout qualifier: $layout_qualifier" ;;
		esac
	fi

	if is_compose_module "$proj_dir" "$modulename"; then
		die "Cannot create XML layout in a Compose project"
	fi
	
	local layout_dir="$proj_dir/$(echo "$modulename" | sed "s#:#/#g")/src/main/res/layout$qualifier"
	mkdir -p "$layout_dir"

	local layout_file="$layout_dir/$layoutname.xml"
	[[ -f "$layout_file" ]] && die "Layout already exists: $layout_file"

	cp "$TEMPLATE_ROOT/scaffolds/layout.xml" "$layout_file"
	log "Adding a layout to Project: $(project_name_for "$proj_dir")"
	log "Added Layout: res/layout$qualifier/$layoutname.xml successfully"
}

create_activity()	{
	local proj_dir="${1:-$(current_project_root "$action_projectname")}"
	[[ -z "$proj_dir" ]]  && exit
	
	local project="$(basename "$proj_dir")"

	[[ -z "$activity" ]] && die "Activity name required (use --activity <Name>)"

	
	local lang="${language,,:-}"
	[[ -z "$lang" ]] && lang="${LANG:-kotlin}"

	if $is_fragment; then
		layoutname="${layoutname:-$(echo "${activity,,}" | sed "s/fragment//")_fragment}"
	else
		layoutname="${layoutname:-activity_$(echo "${activity,,}" | sed "s/activity$//")}"
	fi

	local log_msg=""
	
	if ! is_multi_module_project "$proj_dir" && [[ -z "$modulename" ]]; then
		modulename="$(modules_for "$proj_dir")"
	elif [[ -n "$modulename" && ! -d "$proj_dir/$(echo "$modulename" | sed "s#:#/#g")" ]]; then
		die "Module '$modulename' does not exist. Run cmdapk --add-module $modulename to create it."
	elif [[ -z "$modulename" ]] && is_multi_module_project "$proj_dir"; then
		die "Module is required to create an Activity in a multi module project. Run cmdapk --module <name> --activity <name> [ --packagename <name> --layout <name> ]"
	fi


	if is_compose_module "$project" "$modulename"; then
		lang="compose"
		log_msg="a Compose Activity"
	fi
	
	if [[ "$is_compose" == true ]]; then
		if ! is_compose_module "$project" "$modulename"; then
			die "Cannot create Compose Activity: project is not configured for compose"
		fi
	fi
	
	local ext="java"
	# if lang is empty set it to environment LANG or kotlin if LANG is not set
	[[ -z "$lang" ]] && lang="${LANG:-kotlin}"
	if [[ "$lang" == "compose" || "$lang" == "kotlin" ]]; then
		ext="kt"
	fi

	if [[ "$lang" == "java" || "$lang" == "kotlin" ]]; then
		log_msg="an Activity"
		create_layout "$proj_dir"
	fi

	# modulename="${modulename:-}"

	local gradle_file="$(gradle_file_for "$proj_dir" "$modulename")"
	local module_id="$(module_type "$gradle_file")"

	if [[ "$module_id" != "com.android.application" && "$module_id" != "com.android.library" ]]; then
		die "Can not create Activity in a non Android module"
	fi

	if [[ "$module_id" == "com.android.application" ]]; then
		module_id="app"
	else
		module_id="library"
	fi
	
	local pkg=""
	pkg="${packagename:-$(project_package_for "$proj_dir" "$modulename")}"
	
	if [[ -z "$pkg" ]]; then
		die "Could not determine package name: no 'namespace' found in $modulename/build.gradle(.kts). \
		Please pass --package-name explicitly, or add a namespace to your Gradle config"
	fi
	
	local pkg_path="$(echo "$pkg" | sed "s#\.#/#g")"
	local java_root="$(source_dir_for "$proj_dir")/$pkg_path"

	mkdir -p "$java_root"
	# Check for duplicates ignoring extension
	if files=$(file_exists_ignore_ext "$java_root/$activity"); then
		die "Activity already exist: $files"
	fi
	
	local template_root="$TEMPLATE_ROOT/project/variants/app"
	local activity_path="$template_root/$lang/activity.$ext"

	if $is_fragment; then
		activity_path="$TEMPLATE_ROOT/scaffolds/FragmentActivity.$ext"
	fi
	
	# copy Activity template directly
	cp "$activity_path" "$java_root/$activity.$ext"

	find "$java_root" -type f -name "$activity.$ext" -exec sed -i \
			-e "s#__PACKAGE_NAME__#${pkg}#g" \
			-e "s#__ACTIVITY_NAME__#${activity}#g" \
			-e "s#__CLASS_NAME__#${activity}#g" \
			-e "s#__LAYOUT_NAME__#${layoutname}#g" {} +

	log "Adding ${log_msg} to Project: $(project_name_for "$proj_dir")"
	log "Added Activity: '$activity.$ext' to package $pkg successfully"
}

create_class()	{
	local proj_dir="${1:-$(current_project_root "$action_projectname")}"
	[[ -z "${proj_dir}" ]] && exit
	
	local project="$(basename "$proj_dir")"
	[[ -z "$classname" ]] && die "Class name required (use --class <Name>)"

	if ! is_multi_module_project "$proj_dir" && [[ -z "$modulename" ]]; then
		modulename="$(modules_for "$proj_dir")"
	elif [[ -n "$modulename" && ! -d "$proj_dir/$(echo "$modulename" | sed "s#:#/#g")" ]]; then
		die "Module '$modulename' does not exist. Run cmdapk --add-module $modulename to create it."
	elif [[ -z "$modulename" ]]; then
		die "Module required to create a class in a multi module project. Run cmdapk --module <name> --class <name> [ --packagename <name> --layout <name> ]"
	fi
	
	local pkg=""
	pkg="${packagename:-$(project_package_for "$proj_dir" "$modulename")}"
		
	if [[ -z "$pkg" ]]; then
		die "Could not determine package name: no 'namespace' found in app/build.gradle(.kts). \
		Please pass --packagename explicitly, or add a namespace to your Gradle config"
	fi
	
	local lang="${language,,:-}"
	[[ -z "$lang" ]] && lang="${LANG:-kotlin}"

	if $is_compose; then
		lang="compose"
	fi

	# echo $proj_dir

	local ext="java"
	if [[ "$lang" == "kotlin" || "$lang" == "compose" ]]; then
		ext="kt"
	fi

	
	local pkg_path="$(echo "${pkg,,}" | sed "s#\.#/#g")"
	local java_root="$(source_dir_for "$proj_dir")/$pkg_path"

	# Check for duplucate classes ignoring extension
	if files=$(file_exists_ignore_ext "$java_root/$classname"); then
		die "Class already exist: $files"
	fi
	
	mkdir -p "$java_root"

	local template_root="$TEMPLATE_ROOT/scaffolds"
	
	# copy Class template directly
	cp "$template_root/${lang^}Class.$ext" "$java_root/$classname.$ext"

	find "$java_root" -type f -name "$classname.$ext" -exec sed -i \
			-e "s#__PACKAGE_NAME__#${pkg}#g" \
			-e "s#__CLASS_NAME__#${classname}#g" {} +

	log "Adding Class to Project: $(project_name_for "$proj_dir")"
	log "Added '$classname.$ext' in package '$pkg' successfully"
}
