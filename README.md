## Setup

Prepare instance:
* Add NOPASSWD to visudo `%sudo   ALL=(ALL) NOPASSWD:ALL`
* Prepare access with ssh key

0-init.yml
```bash
ansible-playbook \
	--ssh-common-args "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o IdentityFile=~/.ssh/your_instance_name_rsa" \
	-e "ssh_public_key=~/.ssh/your_public_key_to_work_with_instance.pub" \
	-i machines.ini setup.yml
```
1-git.yml
```bash
ansible-playbook \
	--ssh-common-args "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o IdentityFile=~/.ssh/<your_key_to_work_with_instance>" \
	-e "git_ssh_public_key=~/.ssh/<your_public_key_for_git.pub>" \
	-i machines.ini 1-git.yml
```
2-bugout.yml
```bash
ansible-playbook \
	--ssh-common-args "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o IdentityFile=~/.ssh/<your_key_to_work_with_instance>" \
	-i machines.ini 2-bugout.yml
```

