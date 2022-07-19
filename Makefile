SLEEPTIME ?= 100
WORKSPACE ?= stage

all: init plan apply pause deploy

init:
	cd ./terraform/vpc-01 && terraform init && terraform workspace new $(WORKSPACE) 

plan:
	cd ./terraform/vpc-01 && terraform workspace select $(WORKSPACE)  && terraform plan

apply:
	cd ./terraform/vpc-01 && terraform apply -auto-approve

destroy:
	cd ./terraform/vpc-01 && terraform workspace select $(WORKSPACE) && terraform destroy -auto-approve && terraform workspace select default && terraform workspace delete $(WORKSPACE)

clean:
	cd ./terraform/vpc-01 &&  rm -f terraform.tfplan
	cd ./terraform/vpc-01 &&  rm -f .terraform.lock.hcl
	cd ./terraform/vpc-01 &&  rm -fr terraform.tfstate*
	cd ./terraform/vpc-01 &&  rm -fr .terraform/

pause:
	echo "Wait $(SLEEPTIME) seconds. "
	sleep $(SLEEPTIME)

deploy:
	echo "Run an ansible playbook: "
	cd ./ansible && source .env.news-app && ansible-playbook -i inventory/yc site.yml

reconfig:
	cd ./ansible && source .env.news-app && ansible-playbook -i inventory/yc site.yml -t config
