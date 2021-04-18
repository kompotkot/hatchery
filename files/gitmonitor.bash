#!/usr/bin/env bash

set -eu

function get_entry {
    local entry=$(bugout entries search \
        --token "$BUGOUT_GITMONITOR_TOKEN" \
        --journal "$BUGOUT_GITMONITOR_JOURNAL_ID" \
        "$1")
    echo "$entry"
}

# Extract dashboard entry
git_dashboard_entry=$(get_entry "role:dashboard")
git_dashboard_entry_results=$(echo $git_dashboard_entry | jq -r '.total_results')
if [ $git_dashboard_entry_results -eq 0 ]; then
    echo "Dashboard entry doesn't exist"
fi

git_dashboard_entry_id=$(echo $git_dashboard_entry | jq -r '.results[0].entry_url' | awk -F "/" '{print $NF}')

# Set git server variables
git_path="/srv/git"

git_dashboard_title="Git Server Dashboard"
git_dashboard_repos_content=$(ls $git_path | awk -F " " '{print $1}')
git_dashboard_repos_content=""

# Process each repository
for repo in /srv/git/*.git; do
    repo_name=$(basename $repo | cut -d "." -f "1")
    repo_entry=$(get_entry "#repo:$repo_name")
    repo_entry_results=$(echo $repo_entry | jq -r '.total_results')
    repo_branches=$(ls $repo/refs/heads | awk -F " " '{print $1}')
    entry_title="Reposiotry - $repo_name"
    entry_content="
### Branches
\`\`\`bash
$repo_branches
\`\`\`
"
    if [ $repo_entry_results -eq 0 ]; then
        echo "Creating new entry for $repo_name repository"
        sleep 3
        bugout entries create --token "$BUGOUT_GITMONITOR_TOKEN" \
            --journal "$BUGOUT_GITMONITOR_JOURNAL_ID" \
            --title "$entry_title" \
            --tags "repo:$repo_name"
            --content "$entry_content"
    else
        entry_id=$(echo $repo_entry | jq -r '.results[0].entry_url' | awk -F "/" '{print $NF}')
        echo "Updating $repo_name repository data"
        sleep 3
        bugout entries update --token "$BUGOUT_GITMONITOR_TOKEN" \
            --id "$entry_id" \
            --journal "$BUGOUT_GITMONITOR_JOURNAL_ID" \
            --title "$entry_title" \
            --content "$entry_content"
    fi
    repo_content=$(ls $repo | awk -F " " '{print $1}')
    git_dashboard_repos_content+="
###$repo_name repository
\`\`\`bash
$repo_content
\`\`\`
"
    repo_entry=$(bugout entries search --token "$BUGOUT_GITMONITOR_TOKEN" --journal "$BUGOUT_GITMONITOR_JOURNAL_ID" "#repo:$repo")
done

sleep 3

bugout entries update --token "$BUGOUT_GITMONITOR_TOKEN" \
    --id "$git_dashboard_entry_id" \
    --journal "$BUGOUT_GITMONITOR_JOURNAL_ID" \
    --title "$git_dashboard_title" \
    --content "$git_dashboard_repos_content"

