plugins {
	java
	alias(libs.plugins.spring.boot) apply false
}

group = "com.xi9d"
version = "0.0.1-SNAPSHOT"

subprojects {
	apply(plugin = "java")

	group = rootProject.group
	version = rootProject.version

	extensions.configure<JavaPluginExtension> {
		toolchain { languageVersion.set(JavaLanguageVersion.of(21)) }
	}

	tasks.withType<Test>().configureEach { useJUnitPlatform() }
}
