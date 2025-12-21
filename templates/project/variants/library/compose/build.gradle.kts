plugins	{
	id("com.android.library")
	id("org.jetbrains.kotlin.android")
	id("org.jetbrains.kotlin.plugin.compose")
}

android	{
	namespace = "__NAMESPACE__"
	compileSdk = __COMPILE_SDK__
	defaultConfig	{
		minSdk = __MIN_SDK__
		targetSdk = __TARGET_SDK__
		versionCode = 1
		versionName = "1.0"
		consumerProguardFiles("consumer-rules.pro")
	}

	buildTypes	{
		debug {
		  debuggable = true
		}
	}
	
	buildFeatures {
		compose = true
	}
}

java	{
	toolchain	{
		languageVersion = JavaLanguageVersion.of(17)
	}
}

dependencies	{
  implementation(platform("androidx.compose:compose-bom:2025.08.00"))
  
  implementation("androidx.core:core-ktx:1.17.0")
  implementation("androidx.startup:startup-runtime:1.2.0")
  implementation("androidx.activity:activity-compose:1.9.3")
  implementation("androidx.compose.ui:ui-tooling-preview:1.5.3")
  implementation("androidx.compose.material3:material3:1.1.2")
  debugImplementation("androidx.compose.ui:ui-tooling:1.5.3")
  debugImplementation("androidx.compose.ui:ui-test-manifest:1.5.3")
	implementation(fileTree("libs") {
	  include("*jar","aar")
	})
}
