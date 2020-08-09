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

.PHONY : clean-kind
clean-kind :
	kind delete cluster

.PHONY : clean-docker
clean-docker :
	docker system prune -a -f --volumes

.PHONY : clean-skaffold
clean-skaffold :
	rm -rf ~/.skaffold/

.PHONY : clean-all
clean-all :
	kind delete cluster && docker system prune -a -f --volumes && rm -rf ~/.skaffold/
