// Intentionally empty.
//
// This module has no framework dependencies and must stay that way.
// Java, JUnit and AssertJ come from the root build file.
// If you find yourself wanting to add something here, that is the
// signal to stop and ask whether it belongs behind a port instead.
plugins {
    java

}
java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}
tasks.register("assertNoFramework") {
    val classpath = configurations.named("compileClasspath")
    doLast {
        val banned = classpath.get().files
            .map { it.name }
            .filter { it.startsWith("spring") ||
                    it.startsWith("jakarta.persistence") ||
                    it.startsWith("jackson") ||
                    it.startsWith("hibernate") }
        require(banned.isEmpty()) {
            "Framework libraries on the domain compile classpath: $banned"
        }
    }
}