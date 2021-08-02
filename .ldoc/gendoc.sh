#!/usr/bin/env bash

# place this file in mod ".ldoc" directory


d_ldoc="$(dirname $(readlink -f $0))"
f_config="${d_ldoc}/config.ld"

cd "${d_ldoc}/.."

d_root="$(pwd)"
d_export="${d_export:-${d_root}/docs/reference}"
d_data="${d_export}/data"

cmd_ldoc="${d_ldoc}/ldoc/ldoc.lua"
if test ! -x "${cmd_ldoc}"; then
	cmd_ldoc="ldoc"
fi

# clean old files
rm -rf "${d_export}"

# generate new doc files
"${cmd_ldoc}" --UNSAFE_NO_SANDBOX --multimodule -c "${f_config}" -d "${d_export}" "${d_root}"; retval=$?

# check exit status
if test ${retval} -ne 0; then
	echo -e "\nan error occurred (ldoc return code: ${retval})"
	exit ${retval}
fi

# copy textures to data directory
echo -e "\ncopying textures ..."
mkdir -p "${d_data}"
texture_count=0
for png in $(find "${d_root}/textures" -maxdepth 1 -type f -name "*.png"); do
	t_png="${d_data}/$(basename ${png})"
	if test -f "${t_png}"; then
		echo "WARNING: not overwriting existing file: ${t_png}"
	else
		cp "${png}" "${d_data}"
		texture_count=$((texture_count + 1))
		printf "\rcopied ${texture_count} textures"
	fi
done

echo -e "\n\nDone!"
