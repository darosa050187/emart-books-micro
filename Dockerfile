FROM openjdk:8

WORKDIR /usr/src/app/
COPY --from=BUILD_IMAGE /var/lib/jenkins/workspace/landing-page_feature-login-start/tmp/emart-books-micro/book-work-0.0.1-SNAPSHOT.jar ./book-work-0.0.1.jar

EXPOSE 9000
ENTRYPOINT ["java","-jar","book-work-0.0.1.jar"]
# Test
