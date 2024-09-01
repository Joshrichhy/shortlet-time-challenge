FROM maven:3.8.7 as build
COPY . .
RUN mvn -B clean package -DskipTests

FROM openjdk:17-jdk-slim
COPY --from=build ./target/*.jar time.jar
ENTRYPOINT ["java", "-jar", "-Dserver.port=8678","time.jar"]