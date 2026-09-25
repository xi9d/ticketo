rootProject.name = "ticketo"


include("messaging", "api", "domain", "persistence")


dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories { mavenCentral() }
}