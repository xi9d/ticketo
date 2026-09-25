plugins {
    java
    alias(libs.plugins.spring.boot)
//    id("org.springframework.boot")
//    id("io.spring.dependency-management")
}
dependencies {
    implementation(platform(libs.spring.boot.bom))

    implementation(project(":domain"))
    implementation(project(":persistence"))
    implementation(project(":messaging"))

    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-actuator")

    testImplementation("org.springframework.boot:spring-boot-starter-test")
}