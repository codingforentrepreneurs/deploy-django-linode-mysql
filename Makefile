tf_console:
	terraform -chdir=devops/tf/ console

tf_plan:
	terraform -chdir=devops/tf/ plan

tf_apply:
	terraform -chdir=devops/tf/ apply

tf_upgrade:
	terraform -chdir=devops/tf/ init -upgrade

ansible:
	ANSIBLE_CONFIG=devops/ansible/ansible.cfg venv/bin/ansible-playbook devops/ansible/main.yaml

infra_up:
	terraform -chdir=devops/tf/ apply
	ANSIBLE_CONFIG=devops/ansible/ansible.cfg venv/bin/ansible-playbook devops/ansible/main.yaml

infra_down:
	terraform -chdir=devops/tf/ apply -destroy

infra_init:
	terraform -chdir=devops/tf/ init -backend-config=backend