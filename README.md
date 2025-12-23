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

# Automating via github action

1. Create Workload Identity pool and provider (github)
2. Create a service account that will do terraform provisioning via github action
3. Create bucket for terraform state file
4. Enable gcp state file in version.tf
5. Comment Cloud function until ArtifactRegistry is created by GithubAction Terraform
6. Create Github action check auth is ok
7. Enable github action create artifact registry
8. Create Github action to push image to the artifact registry
9. Enable cloud run to deploy Spring boot application
10. Only code change and push