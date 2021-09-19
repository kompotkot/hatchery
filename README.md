# hatchery

## Content

-   `files_distributor` - AWS lambda serverless application to store files
-   `gitmonitor` - Setup of personal Git server with monitoring via journal at Bugout.dev
-   `initial` - common playbooks to deploy server

## Initial installation

Prepare instance for ansible playbook:

-   Add NOPASSWD to visudo `%sudo ALL=(ALL) NOPASSWD:ALL`
-   Prepare access with ssh key
-   Apply playbook

```bash
ansible-playbook \
	--ssh-common-args "-o UserKnownHostsFile=/dev/null \
	-o StrictHostKeyChecking=no \
	-o IdentityFile=~/.ssh/your_instance_name_rsa" \
	-e "ssh_public_key=~/.ssh/your_public_key_to_work_with_instance.pub" \
	-i machines.ini setup.yml
```
