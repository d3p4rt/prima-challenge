CLUSTER_NAME := prima-tech-challenge
REGION       := eu-south-1
VPC_ID       := $(shell aws ec2 describe-vpcs --filters "Name=tag:Name,Values=eks-vpc" --query "Vpcs[0].VpcId" --output text)

.PHONY: install-ingress-controller

install-ingress-controller:
	helm repo add eks https://aws.github.io/eks-charts
	helm repo update
	
	helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
		-n kube-system \
		--set clusterName=$(CLUSTER_NAME) \
		--set serviceAccount.create=false \
		--set serviceAccount.name=aws-load-balancer-controller \
		--set region=$(REGION) \
		--set vpcId=$(VPC_ID) \
		--set terminationGracePeriodSeconds=0