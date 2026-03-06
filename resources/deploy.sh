#!/bin/env bash

az deployment group create \
	--template-file main.bicep \
	--resource-group rg-explorer-dev-westeu-001 \
