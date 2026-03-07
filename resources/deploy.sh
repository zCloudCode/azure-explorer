#!/bin/env bash

az stack group create \
	--template-file main.bicep \
	--resource-group rg-explorer-dev-westeu-001 \
	--name explorerResources \
	--deny-settings-mode none \
	--action-on-unmanage deleteResources \
	--parameters sshKeyData="$(cat $SSH_KEY_FILE)"
