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

# ---------- Argument parsing (supports --opt=value and --opt value) --------------------
# We'll populate these variable from args
projectname=""
packagename=""
activity=""
classname=""
layoutname=""
modulename=""
appname=""
compile_target=""
install_target=""
language="java" #default
min_sdk=""
target_sdk=""
help_req=""
layout_qualifier=""

# option flags
is_compose=false
is_release=false
is_library=false
is_fragment=false
no_install=false
no_strict=false
bundle_aab=false


parse_args()	{
	# convert arguments to while loop
	while [[ $# -gt 0 ]];do
		arg="$1"
		case "$arg" in
			--new-project=*) projectname="${arg#*=}"; shift;;
			--package-name=*) packagename="${arg#*=}"; shift;;
			--app-name=*) appname="${arg#*=}"; shift;;
			--add-module=*) modulename="${arg#*=}"; shift;;
			--module=*) modulename="${arg#*=}"; shift;;
			--activity=*) activity="${arg#*=}"; shift;;
			--class=*) classname="${arg#*=}"; shift;;
			--layout=*) layoutname="${arg#*=}"; shift;;
			--compile=*) compile_target="${arg#*=}"; shift;;
			--install=*) install_target="${arg#*=}"; shift;;
			--qualifier=*) layout_qualifier="${arg#*=}"; shift;;
			--lang=*) language="${arg#*=}"; shift;;
			--minsdk=*) min_sdk="${arg#*=}"; shift;;
			--targetsdk=*) target_sdk="${arg#*=}"; shift;;

			# Flags/Modifiers
			--aab*) bundle_aab=true; shift;;
			--library) is_library=true; shift;;
			--fragment) is_fragment=true; shift;;
			--compose) is_compose=true; shift;;
			--release) is_release=true; shift;;
			--no-install) no_install=true; shift;;
			
			-h|--help) usage; exit 0 ;;
			--*) #support "--opt value" form
			opt="${arg#--}"
			case "$opt" in
				new-project|app-name|add-module|module|package-name|activity|class|layout|compile|install|lang|minsdk|maxsdk)
				if [[ $# -lt 2 || "$2" == --* ]];then
					die "--$opt requires a value"
				fi

				val="$2"; shift 2
				case "$opt" in
					new-project) projectname="$val" ;;
					package-name) packagename="$val" ;;
					module) modulename="$val" ;;
					app-name) appname="$val" ;;
					add-module) modulename="$val" ;;
					activity) activity="$val" ;;
					class) classname="$val" ;;
					layout) layoutname="$val" ;;
					qualifier) layout_qualifier="$val" ;;
					compile) compile_target="$val" ;;
					install) install_target="$val" ;;
					lang) language="$val" ;;
					minsdk) min_sdk="$val" ;;
					maxsdk) max_sdk="$val" ;;
				esac
				;;
				*) die "Unknown option: $arg" ;
			esac
			;;
			*) # positional argument (maybe target project)
			err "Unkown option $arg"
			echo
			shift
			;;
		esac
	done
}
