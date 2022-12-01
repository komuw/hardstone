DOCKER_REGISTRY=komuw
PROJECT_NAME=debug
ALTREPO=$(DOCKER_REGISTRY)/$(PROJECT_NAME)

build:
	docker ps -aq | xargs docker rm -f;docker volume ls -q | xargs docker volume rm -f | echo ''
	docker build -t "${ALTREPO}:latest" .

push: build
	docker push --all-tags $(ALTREPO)
