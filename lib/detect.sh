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

is_compose_module()	{
	local proj_dir="$(project_path_for "$1")"
	local gradle_file="$(gradle_file_for "$proj_dir" "$2")"

	[[ -z "$gradle_file" ]] && return 1

	# Match both Groovy (compose true) and morden style (compose = true)
	grep -Eq 'compose[[:space:]]*(=)?[[:space:]]*true' "$gradle_file"
}

is_multi_module_project()	{
	local proj_dir="$(project_path_for "$1")"
	# local modules
	IFS=' ' read -r -a modules <<< "$(modules_for "$proj_dir")"
	# echo "${modules[@]}"

	if (( ${#modules[@]} > 1 )); then
		return 0;
	else
		return 1;
	fi
}

module_type()	{
	local gradle_file="$1"

	# Must exist and be a file
	if [[ ! -f "$gradle_file" ]]; then
		return 1
	fi

	local regex="\s*id\s?('|\")"
	local module_id="$(grep -E $regex "$gradle_file" | sed "s/\s*id\s*//" | tr -d '"' | tr -d "'")"

	[[ -z "$module_id" ]] && return 1

	echo "$module_id"
	
	return 0
}
