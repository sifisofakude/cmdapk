# 
#  Copyright 2025 Sifiso Fakude
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
param (
	[string]$ProjectName,
	# [string]$ProjectNameValue
	[string]$packagename,
	[string]$appname,
	[string]$activity = "MainActivity",
	[string]$layout = "activity_main",
	[string]$minsdk = 23,
	[int]$MaxSdk = 35,
	[string]$Lang = "java",
	[string]$Plain,
	[string]$Theme,
	[string]$Compile,
	[string]$Install
)

$script_root = $PSScriptRoot -replace '/','\'
. "$script_root\..\etc\settings.ps1"

if($PROJECT_DIR -eq $null -or $PROJECT_DIR -eq "")	{
	Write-Output "Please set PROJECT_DIR in ../etc/settings.ps1 or uncomment it if commented" 
	exit
}


function Usage	{
	$space = " "
	Write-Output " usage: \path\to\cmdapk.ps1 -projectname Name [-packagename com.example.app]"
	Write-Output ""
	Write-Output "        \path\to\cmdapk.ps1 --Compile ProjectDirectory"
	Write-Output ""
	Write-Output " options:"
	Write-Output "    -projectname    param       Name of the project to be created, param will stripped of all spaces."
	Write-Output ""
	Write-Output "    -packagename    param       Package name,defaults to com.example.projectname"
	Write-Output ""
	Write-Output "    -appname        param       Display name for the application"
	Write-Output ""
	Write-Output "    -activity       param       Default launcher activity for the application"
	Write-Output ""
	Write-Output "    -layout         param       Main layout for application ui"
	Write-Output ""
	Write-Output "    -plain          param       Generate a plain activity without using AndroidX libraries"
	Write-Output ""
	Write-Output "    -minsdk         param       Minimum SDK API level the application will be compatible with"
	Write-Output ""
	Write-Output "    -maxsdk         param       Maximum SDK API level the application will be compatible with"
	Write-Output ""
	Write-Output "    -lang           param       Language to create main activity with (java/kotlin), defaults to java"
	Write-Output ""
	Write-Output "    -theme          param       Root theme for application."
	Write-Output ""
	Write-Output "    -compile        [param]     Compiles project from current directory or a specific one if param is provided."
	Write-Output "                                 Upon successful compile the application will be installed automatically to available"
	Write-Output "                                 devices, make sure only one device/emulator connected"
	Write-Output ""
	Write-Output "    -install        [param]     Install app from current directory or a specific one if param is provided."
}

if($ProjectName)	{
	$proj_name = $ProjectName -replace ' ',''

	if($proj_name.StartsWith("-"))	{
		Usage
		exit
	}

	if(Test-Path "$PROJECT_DIR\$proj_name")	{
		Write-Output "Project already exist"
		exit
	}else	{
		New-Item -ItemType Directory -path $PROJECT_DIR\$proj_name 2> $null
	}

	if($AppName.StartsWith("-"))	{
		$AppName = "$proj_name"
	}

	if($PackageName.StartsWith("-"))	{
		$PackageName = "com.exmple.$proj_name".ToLower()
	}

	if($Activity.StartsWith("-"))	{
		$Activity = "MainActivity"
	}

	if($Layout.StartsWith("-"))	{
		$Layout = "activity_main"
	}

	if($Lang.StartsWith("-"))	{
		$Lang = "java"
	}

	if($Lang.StartsWith("-"))	{
		$Lang = "java"
	}

	if($Plain.StartsWith("-"))	{
		$Plain = $null
	}

	if($Theme.StartsWith("-"))	{
		$Theme = $null
	}

	if($minsdk -is [string])	{
		$minsdk = 23
	}

	if($maxsdk -is [string])	{
		$maxsdk = 35
	}

	# Create the directory structure for th app
	New-Item -ItemType Directory -path $PROJECT_DIR\$proj_name\app\libs 2> $null
	New-Item -ItemType Directory -path $PROJECT_DIR\$proj_name\app\src\main\java 2> $null
	New-Item -ItemType Directory -path $PROJECT_DIR\$proj_name\app\src\main\assets 2> $null
	New-Item -ItemType Directory -path $PROJECT_DIR\$proj_name\app\src\main\res\layout 2> $null
	New-Item -ItemType Directory -path $PROJECT_DIR\$proj_name\app\src\main\res\values 2> $null

	$template_root = Resolve-Path "$script_root\..\templates"
	if($Plain -eq $null -or $Plain.Trim() -eq "")	{
		$app_theme = "Theme.AppCompat.DayNight.NoActionBar"
		$sample_path = Resolve-Path "$template_root\androidx-sample"
	}else	{
		$app_theme = "Theme.Holo"
		$sample_path = Resolve-Path "$template_root\android-sample"
	}

	Copy-Item -Path "$template_root\build.gradle" -Destination "$PROJECT_DIR\$proj_name\"
	Copy-Item -Path "$template_root\gradle.properties" -Destination "$PROJECT_DIR\$proj_name\"
	Copy-Item -Path "$template_root\local.properties" -Destination "$PROJECT_DIR\$proj_name\"
	Copy-Item -Path "$template_root\proguard-rules.pro" -Destination "$PROJECT_DIR\$proj_name\app\"
	Copy-Item -Path "$sample_path\layout.slam" -Destination "$PROJECT_DIR\$proj_name\app\src\main\res\layout\$Layout.xml"
	
	Copy-Item -Path "$template_root\drawable" -Destination "$PROJECT_DIR\$proj_name\app\src\main\res\" -Recurse 2> $null
	Copy-Item -Path "$template_root\mipmap-mdpi" -Destination "$PROJECT_DIR\$proj_name\app\src\main\res\" -Recurse 2> $null
	Copy-Item -Path "$template_root\mipmap-hdpi" -Destination "$PROJECT_DIR\$proj_name\app\src\main\res\" -Recurse 2> $null
	Copy-Item -Path "$template_root\mipmap-xhdpi" -Destination "$PROJECT_DIR\$proj_name\app\src\main\res\" -Recurse 2> $null
	Copy-Item -Path "$template_root\mipmap-anydpi-v26" -Destination "$PROJECT_DIR\$proj_name\app\src\main\res\" -Recurse 2> $null

	$current_file = "$template_root\AndroidManifest.slam"
	$output_file = "$PROJECT_DIR\$proj_name\app\src\main\AndroidManifest.xml"
	Get-Content $current_file | ForEach-Object	{
		# Write-Output $_
		$_ -creplace 'ACTIVITY',$Activity
	} | Set-Content $output_file

	$current_file = "$template_root\local.properties"
	$output_file = "$PROJECT_DIR\$proj_name\local.properties"
	Get-Content $current_file | ForEach-Object	{
		# Write-Output $_
		$line = $_
		if($line -eq "sdk.dir=")	{
			if(Test-Path "$ANDROID_SDK")	{
				$line = "$line$ANDROID_SDK"
			}else	{
				$line = "#$line"
			}
		}
		
		if($line -eq "ndk.dir=")	{
			if(Test-Path "$ANDROID_NDK")	{
				$line = "$line$ANDROID_NDK"
			}else	{
				$line = "#$line"
			}
		}
		$line
	} | Set-Content $output_file

	$current_file = "$template_root\settings.gradle"
	$output_file = "$PROJECT_DIR\$proj_name\settings.gradle"
	Get-Content $current_file | ForEach-Object	{
		# Write-Output $_
		$_ -replace 'PROJ_NAME',$proj_name
	} | Set-Content $output_file

	$current_file = "$template_root\strings.slam"
	$output_file = "$PROJECT_DIR\$proj_name\app\src\main\res\values\strings.xml"

	if($AppName -eq $null -or $AppName.Trim() -eq "" -or $AppName.StartsWith("-"))	{
		$app_name = $proj_name
	}else	{
		$app_name = $AppName
	}
	
	Get-Content $current_file | ForEach-Object	{
		# Write-Output $_
		$_ -creplace 'APP_NAME',$app_name
	} | Set-Content $output_file

	$current_file = "$template_root\styles.slam"
	$output_file = "$PROJECT_DIR\$proj_name\app\src\main\res\values\styles.xml"

	if($Theme -ne $null -or $Theme.Trim() -ne "")	{
		$app_name = $Theme
	}
	
	Get-Content $current_file | ForEach-Object	{
		# Write-Output $_
		$_ -creplace 'THEME_PARENT',$app_theme
	} | Set-Content $output_file

	$current_file = "$sample_path\build.gradle"
	$output_file = "$PROJECT_DIR\$proj_name\app\build.gradle"
	
	if($PackageName -eq $null -or $PackageName.Trim() -eq "")	{
		$pkg_name = "com.example.$proj_name".ToLower()
	}else	{
		if($PackageName.StartsWith("-"))	{
			$pkg_name = "com.example.$proj_name".ToLower()
		}else	{
			$pkg_name = $PackageName -replace ' ',''
		}
	}
	
	Get-Content $current_file | ForEach-Object	{
		# Write-Output $_
		$line = $_
		$line = $line -creplace 'PKG_NAME',$pkg_name
		$line = $line -creplace 'COMP_SDK',$MaxSdk
		$line = $line -creplace 'MAX_SDK',$MaxSdk
		$line = $line -creplace 'MIN_SDK',$MinSdk

		$line
	} | Set-Content $output_file

	
	$java_src = "$PROJECT_DIR\$proj_name\app\src\main\java\$pkg_name" -replace '\.','\'
	New-Item -ItemType Directory -path $java_src > $null

	if($Lang -eq "java")	{
		$file_extension = "java"
		$current_file = "$sample_path\java\activity.slam"
	}else	{
		$current_file = "$sample_path\kotlin\activity.slam"
		$file_extension = "kt"

		Get-Content "$template_root\kotlin_build.gradle" | ForEach-Object	{
			$line = $_
			$line = $line -creplace 'PKG_NAME',$pkg_name
			$line = $line -creplace 'COMP_SDK',$MaxSdk
			$line = $line -creplace 'MAX_SDK',$MaxSdk
			$line = $line -creplace 'MIN_SDK',$MinSdk
			$line = $line -creplace 'ACTIVITY',$activity

			$line
		} | Set-Content "$PROJECT_DIR\$proj_name\app\build.gradle"
	}

	$output_file = "$java_src\$Activity.$file_extension"

	Get-Content $current_file | ForEach-Object	{
		# Write-Output $_
		$line = $_
		$line = $line -creplace 'PKG_NAME',$pkg_name
		$line = $line -creplace 'LAYOUT',$Layout
		$line = $line -creplace 'ACTIVITY',$Activity

		$line
	} | Set-Content $output_file
}

if($Compile -ne $null -and $Compile.Trim() -ne "")	{
	Write-Output "Preparing to compile..."
	$env:ANDROID_HOME = "$ANDROID_SDK"
	
	if($Compile -eq ".")	{
		$compile_folder = Get-Location
		$compile_folder = $compile_folder -replace '/','\'
		$compile_folder = ($compile_folder -split '\\')[-1]
	}else	{
		$compile_folder = $Compile
	}

	# Write-Output "$compile_folder"
	$compile_path = "$PROJECT_DIR\$compile_folder"
	if(Test-Path "$compile_path")	{
		cd "$compile_path"
		gradle build
		
		if(Test-Path "app\build\outputs\apk\debug\app-debug.apk")	{
			$install = "."
		}
	}else	{
		Write-Output "Compilation failed. Make sure you are in project root or supply a project name created with PROJECT_DIR"
	}
}

if($Install -ne $null -and $install.Trim() -ne "")	{
	if($Install -eq ".")	{
		$install_folder = Get-Location
		$install_folder = $install_folder -replace '/','\'
		$install_folder = ($install_folder -split '\\')[-1]
	}else	{
		$install_folder = $Install
	}
	$install_path = "$PROJECT_DIR\$install_folder\app\build\outputs\apk\debug\app-debug.apk"
	
	if(Test-Path "$install_path")	{
		$install_debug = Resolve-Path "$install_path"
		adb install $install_debug
	}else	{
		Write-Output "No app to install"
	}
}

if(-not $ProjectName -and -not $Compile -and -not $install)	{
	Usage
}
