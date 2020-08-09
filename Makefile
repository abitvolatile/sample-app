#!/bin/make


### Create Operations

.PHONY : provision
provision :
	kind create cluster --config=kind-config.yaml


.PHONY : dev $(TAG)
dev : $(TAG)
	./start-skaffold-dev.sh ${TAG}


.PHONY : build
build :
	skaffold config set local-cluster false && skaffold build -t ${TAG} && skaffold config set local-cluster true


.PHONY : all $(TAG)
all : $(TAG)
	kind create cluster --config=kind-config.yaml && ./start-skaffold-dev.sh ${TAG}



### Clean Operations

.PHONY : kind-clean
kind-clean :
	kind delete cluster


.PHONY : docker-clean
docker-clean :
	docker system prune -a -f --volumes


.PHONY : skaffold-clean
skaffold-clean :
	rm -rf ~/.skaffold/


.PHONY : clean-all
clean-all :
	kind delete cluster && docker system prune -a -f --volumes && rm -rf ~/.skaffold/
