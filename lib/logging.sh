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

# Normal log (stdout)
log() {
	if [[ "$quiet_mode" == false ]]; then
		printf '[INFO] %s\n' "$*"
	fi
}

# Error log (stderr)
err() {
	printf '[ERROR] %s\n' "$*" >&2;
}

# Error log + exit with code (default 1)
die() {
	local code=1
	if [[ $# -gt 1 && "$1" =~ ^[0-9]+$ ]];then
		code="$1"
		shift
	fi
	err "$*"
	
	exit "$code"
}
