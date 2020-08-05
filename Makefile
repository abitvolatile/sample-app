#!/bin/make

provision:
		./deploy-kind-cluster.sh


deploy:
		./start-skaffold-dev.sh


clean:
		./clean-kind-cluster.sh