#!/usr/bin/env bash

server_ssh_keys_path="/home/ubuntu/.ssh"
server_ssh_git_key="$server_ssh_keys_path/home_internal_id_rsa"
server_ip="192.168.1.85"

read -p "How to call new repository: " repo_name

command_create_repo="sudo mkdir /srv/git/$repo_name.git"
command_init_repo="sudo su -c 'git init --bare /srv/git/$repo_name.git/'"
command_leave_to_git_repo="sudo chown -R git:git /srv/git/$repo_name.git"

ssh -i "$server_ssh_git_key" ubuntu@"$server_ip" \
    "$command_create_repo && $command_init_repo && $command_leave_to_git_repo"
