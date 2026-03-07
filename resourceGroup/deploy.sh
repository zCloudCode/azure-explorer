#!/bin/env bash

az stack sub create \
	--location westeurope \
	--template-file main.bicep \
	--name explorerRG \
	--deny-settings-mode none \
	--action-on-unmanage deleteResources \
	--parameters env=dev

