#! /usr/bin/env bash

# Finds the ID of the latest successful workflow run and stores it to GITHUB_ENV.
#
# Set the following environment varibales before running this command.
#
# GH_TOKEN - Access token with appropriate level of access.
# GH_BRANCH - Branch to filter on (e.g. "master")
# GH_EVENTS - Space-sepated list of trigger events to filter on (e.g. "push workflow_dispatch")
# GH_OUTPUT_VAR - Name of variable to store output to (e.g. "LAST_RUN_ID")
# GH_REPO - Repo to filter on (e.g. "someuser/somerepo")
# GH_WORKFLOW - Name of workflow file (e.g. "myworkflow.yaml")

set -eu -o pipefail

main () {
	local gh_args=(
		--branch "${GH_BRANCH}"
		--jq .[].databaseId
		--json databaseId
		--limit 1
		--repo "${GH_REPO}"
		--status success
		--workflow "${GH_WORKFLOW}"
	)

	local events_array=($GH_EVENTS)
	for e in "${events_array[@]}"; do
		gh_args+=(--event "${e}");
	done

	local tmpfile="$(mktemp)"
	echo "Running gh run list ${gh_args[@]}"
	gh run list "${gh_args[@]}" > "${tmpfile}"

	if [[ -z "$(cat $tmpfile)"  ]]; then
		echo >&2 "Failed to find release"
		exit 1
	fi

	echo "${GH_OUTPUT_VAR}=$(cat $tmpfile)" >> "${GITHUB_ENV}"
	rm -f "${tmpfile}"
}

main
