#!/usr/bin/env bash

set -eu

# Variables
current_date=$(echo $(date '+%Y-%m-%d %H:%M:%S'))
git_path="/srv/git"

function get_entry {
    # Search entry by tag
    local entry=$(bugout entries search \
        --token "$BUGOUT_GITMONITOR_TOKEN" \
        --journal "$BUGOUT_GITMONITOR_JOURNAL_ID" \
        "$1")
    echo "$entry"
}

function process_entry {
    # Update an entry if entry_results is not None,
    # otherwise create a new one
    entry_results=$(echo $1 | jq -r '.total_results')
    if [ $entry_results -eq 0 ]; then
        bugout entries create --token "$BUGOUT_GITMONITOR_TOKEN" \
            --journal "$BUGOUT_GITMONITOR_JOURNAL_ID" \
            --title "$2" \
            --tags "$4" \
            --content "$3"
    else
        entry_id=$(echo $1 | jq -r '.results[0].entry_url' | awk -F "/" '{print $NF}')
        bugout entries update --token "$BUGOUT_GITMONITOR_TOKEN" \
            --id "$entry_id" \
            --journal "$BUGOUT_GITMONITOR_JOURNAL_ID" \
            --title "$2" \
            --content "$3"
    fi
}

# Process dashboard entry
git_dashboard_entry=$(get_entry "role:dashboard")
git_dashboard_title="Git Server Dashboard"
git_dashboard_repos_content=$(ls $git_path | awk -F " " '{print $1}' | cut -d "." -f "1")
entry_dashboard_content="
### Server timestamp
\`\`\`bash
$current_date
\`\`\`
### Repositories
\`\`\`bash
$git_dashboard_repos_content
\`\`\`
"
process_entry "$git_dashboard_entry" "$git_dashboard_title" "$entry_dashboard_content" "role:dashboard"

# Process each repository in $git_path
for repo in /srv/git/*.git; do
    sleep 1
    repo_name=$(basename $repo | cut -d "." -f "1")
    repo_entry=$(get_entry "#repo:$repo_name")
    repo_branches=$(ls $repo/refs/heads | awk -F " " '{print $1}')
    repo_root_directories=$(ls -l $repo)
    repo_entry_title="Reposiotry - $repo_name"
    repo_entry_content="
### Branches
\`\`\`bash
$repo_branches
\`\`\`
### Root repository directory
\`\`\`bash
$repo_root_directories
\`\`\`
"
    process_entry "$repo_entry" "$repo_entry_title" "$repo_entry_content" "repo:$repo_name"
done
