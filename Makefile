#!/bin/make


### Create Operations

.PHONY : provision
provision :
	kind create cluster --config=kind-config.yaml

.PHONY : dev $(TAG) $(NAMESPACE)
dev : $(TAG) $(NAMESPACE)
	./start-skaffold-dev.sh

.PHONY : build $(TAG)
build : $(TAG)
	skaffold config set local-cluster false && skaffold build -t ${TAG} && skaffold config set local-cluster true

.PHONY : all $(TAG) $(NAMESPACE)
all : $(TAG) $(NAMESPACE)
	kind create cluster --config=kind-config.yaml && ./start-skaffold-dev.sh


.PHONY : kube-config
kube-config : 
	cat ~/.kube/config



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
