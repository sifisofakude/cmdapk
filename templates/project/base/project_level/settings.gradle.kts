pluginManagement  {
  repositories  {
    google()
    mavenCentral()
    gradlePluginPortal()
  }
  
  plugins{
    __APPLICATION_GRADLE_PLUGIN__("com.android.application") version "8.13.2" apply false
    __LIBRARY_GRADLE_PLUGIN__("com.android.library") version "8.13.2" apply false
    __COMPOSE_GRADLE_PLUGIN__("org.jetbrains.kotlin.plugin.compose") version "2.0.21" apply false
    id("org.jetbrains.kotlin.android") version "2.2.21" apply false
  }
}

dependencyResolutionManagement	{
	repositoriesMode.set(RepositoriesMode.PREFER_PROJECT)
	repositories  {
		google()
		mavenCentral()
	}
}



rootProject.name = "__PROJECT_NAME__"
