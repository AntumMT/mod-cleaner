#!/usr/bin/env bash

# place this file in mod ".ldoc" directory


d_ldoc="$(dirname $(readlink -f $0))"
f_config="${d_ldoc}/config.ld"

cd "${d_ldoc}/.."

d_root="$(pwd)"
d_ref="${d_root}/docs/reference"
d_data="${d_ref}/data"

cmd_ldoc="${d_ldoc}/ldoc/ldoc.lua"
if test ! -x "${cmd_ldoc}"; then
	cmd_ldoc="ldoc"
fi

# clean old files
rm -rf "${d_ref}"

# create new files
"${cmd_ldoc}" --UNSAFE_NO_SANDBOX -c "${f_config}" -d "${d_ref}" "${d_root}"

# check exit status
retval=$?
if test ${retval} -ne 0; then
	exit ${retval}
fi

# copy textures to data directory
echo -e "\ncopying textures ..."
mkdir -p "${d_data}"
for png in $(find "${d_root}/textures" -maxdepth 1 -type f -name "*.png"); do
	cp -v "${png}" "${d_data}"
done

echo -e "\nDone!"
