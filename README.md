# Getting Started

Create image
```shell
./gradlew bootBuildImage
```
Docker commands

```shell
# europe-west3-docker.pkg.dev/spring-boot-ci-cd-deployment/my-docker-repo
docker tag spring-boot-tf-gcp-sample:1.0.0 europe-west3-docker.pkg.dev/spring-boot-ci-cd-deployment/my-docker-repo/spring-boot-tf-gcp-sample:1.0.0

docker push europe-west3-docker.pkg.dev/spring-boot-ci-cd-deployment/my-docker-repo/spring-boot-tf-gcp-sample:1.0.0

# local run
docker run -d -p 8080:8080 docker.io/library/spring-boot-tf-gcp-sample:1.0.0

```