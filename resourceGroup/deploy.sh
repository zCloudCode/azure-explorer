#!/bin/env bash

az deployment sub create \
	--location westeurope \
	--template-file main.bicep \
	--parameters env=dev

