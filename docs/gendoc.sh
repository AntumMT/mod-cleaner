#!/bin/bash

docs="$(dirname $(readlink -f $0))"
root="$(dirname ${docs})"
config="${docs}/config.ld"

cd "${root}"

# Clean old files
rm -rf "${docs}/reference"

# Create new files
ldoc --UNSAFE_NO_SANDBOX -c "${config}" -d "${docs}/reference" "${root}"
