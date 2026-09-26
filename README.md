# Ticketo
Description here:

# how to run
To run ticketo
1. First clone the project
2. Open the project using your ide and run the following code
<code>
./gradlew build <br>
./gradlew :api:bootRun
</code>

3. To generate all the features need use make file to start the docker local stack
 It includes postgres, kafka, keycloak, prometheus, grafana, jaeger all from this one command
   Verify
    
    make all
    docker compose ps
    
    Six containers, postgres and kafka showing healthy, the other four running (they have no healthchecks defined, so --wait only waits for them to start).
    
    Then stop the extras and get back to your daily state:
    
    make down && make up
# Author
Paul Webo

# License

