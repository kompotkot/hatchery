#!/usr/bin/env bash

server_ssh_git_key="$2"
server_ip="$1"

read -p "How to call new repository: " repo_name

command_create_repo="sudo mkdir /srv/git/$repo_name.git"
command_init_repo="sudo su -c 'git init --bare /srv/git/$repo_name.git/'"
command_leave_to_git_repo="sudo chown -R git:git /srv/git/$repo_name.git"

ssh -i "$server_ssh_git_key" ubuntu@"$server_ip" \
    "$command_create_repo && $command_init_repo && $command_leave_to_git_repo"
