plugins	{
	id("com.android.library")
	id("org.jetbrains.kotlin.android")
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
		  debuggable true
		}
	}
	
	buildFeatures {
		viewBinding = false
	}
}

java	{
	toolchain	{
		languageVersion = JavaLanguageVersion.of(17)
	}
}

dependencies	{
	implementation(fileTree("libs") {
	  include("*.jar","*.aar")
	})
}
