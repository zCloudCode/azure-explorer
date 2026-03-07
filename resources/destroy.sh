#!/bin/env bash

az stack group delete \
	--name explorerResources \
	--action-on-unmanage deleteResources \
	--resource-group rg-explorer-dev-west-001 \
	--yes
