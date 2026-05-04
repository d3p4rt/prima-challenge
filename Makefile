.PHONY: install-lb-controller install-gateway-api-crds setup-cluster

CLUSTER_NAME=prima-tech-challenge
REGION=eu-south-1
ACCOUNT_ID=803871048799

setup-cluster: install-gateway-api-crds install-lb-controller

install-gateway-api-crds:
	kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/latest/download/standard-install.yaml

install-lb-controller:
	helm repo add eks https://aws.github.io/eks-charts
	helm repo update
	helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
		-n kube-system \
		--set clusterName=$(CLUSTER_NAME) \
		--set serviceAccount.create=true \
		--set serviceAccount.name=aws-load-balancer-controller \
		--set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=$(LB_CONTROLLER_ROLE_ARN) \
		--set region=$(REGION) \
		--set vpcId=$(shell aws eks describe-cluster --name $(CLUSTER_NAME) --region $(REGION) --query "cluster.resourcesVpcConfig.vpcId" --output text)