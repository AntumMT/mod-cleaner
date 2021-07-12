#!/bin/bash

docs="$(dirname $(readlink -f $0))"
root="$(dirname ${docs})"
config="${docs}/config.ld"

cd "${root}"

# Clean old files
rm -rf "${docs}/api"

# Create new files
ldoc -c "${config}" -d "${docs}/api" "${root}/api.lua"
