.PHONY: default, secrets, docker-migrate, docker-nginx, docker, xc-deploy-bd, xc-deploy-nginx, deploy, delete

DOCKER_REGISTRY 	   ?= ghcr.io/f5devcentral/xchaawsdemoguide/
DOCKER_REPOSITORY_URI  ?= $(DOCKER_REGISTRY)/


docker-migrate:	
	docker buildx build --no-cache \
		--platform=linux/amd64 \
		--output type=docker \
		--progress plain \
		-t migrate \
		-f ./docker/Dockerfile.migrate.nonroot \
		.
	docker tag migrate $(DOCKER_REPOSITORY_URI)migrate-nonroot:latest
	docker push $(DOCKER_REPOSITORY_URI)migrate-nonroot:latest


docker-nginx:	
	docker buildx build --no-cache \
		--platform=linux/amd64 \
		--output type=docker \
		--progress plain \
		-t openrestypg \
		-f ./docker/Dockerfile.openrestry \
		.
	docker buildx build --no-cache \
		--platform=linux/amd64 \
		--output type=docker \
		--progress plain \
		-t openrestypg-nonroot \
		-f ./docker/Dockerfile.openresty.nonroot \
		.
	docker tag openrestypg $(DOCKER_REPOSITORY_URI)openresty-base:latest
	docker push $(DOCKER_REPOSITORY_URI)openresty-base:latest
	docker tag openrestypg-nonroot $(DOCKER_REPOSITORY_URI)openresty-nonroot:latest
	docker push $(DOCKER_REPOSITORY_URI)openresty-nonroot:latest


docker: docker-migrate, docker-nginx

xc-deploy-bd:
	KUBECONFIG=./ves_ha-services-ce_aws-ha-vk8s.yaml helm dependency build ./helm/postgres
	KUBECONFIG=./ves_ha-services-ce_aws-ha-vk8s.yaml helm dependency update ./helm/postgres
	KUBECONFIG=./ves_ha-services-ce_aws-ha-vk8s.yaml helm upgrade --install ha-postgres ./helm/postgres --values=./helm/postgres/values.yaml

xc-deploy-nginx:
	KUBECONFIG=./ves_ha-services-ce_aws-ha-vk8s.yaml helm upgrade --install nginx-reverseproxy ./helm/nginx --values=./helm/nginx/values.yaml

deploy:	xc-deploy-bd, xc-deploy-nginx

delete:
	KUBECONFIG=./ves_ha-services-ce_aws-ha-vk8s.yaml helm uninstall nginx-reverseproxy
	KUBECONFIG=./ves_ha-services-ce_aws-ha-vk8s.yaml helm uninstall ha-postgres

default: secrets, docker, deploy