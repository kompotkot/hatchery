# hatchery

Prepare instance:
* Add NOPASSWD to visudo `%sudo   ALL=(ALL) NOPASSWD:ALL`
* Prepare access with ssh key

```bash
ansible-playbook \
	--ssh-common-args "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o IdentityFile=~/.ssh/your_instance_name_rsa" \
	-e "ssh_public_key=~/.ssh/your_public_key_to_work_with_instance.pub" \
	-i machines.ini setup.yml
```
