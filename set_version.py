#!/usr/bin/env python

import sys, os, codecs


f_script = os.path.realpath(__file__)
d_root = os.path.dirname(f_script)

os.chdir(d_root)

args = sys.argv[1:]
if len(args) < 1:
	print("ERROR: must supply version as parameter")
	sys.exit(1)

new_version = args[0]

to_update = {
	"mod.conf": "version =",
	"changelog.txt": "next",
	os.path.normpath(".ldoc/config.ld"): "local version =",
}

for f in to_update:
	f_path = os.path.join(d_root, f)
	if not os.path.isfile(f_path):
		print("WARNING: {} not found, skipping ...".format(f))
		continue

	print("\nsetting version to {} in {}".format(new_version, f_path))

	buffer = codecs.open(f_path, "r", "utf-8")
	if not buffer:
		print("WARNING: could not open {} for reading, skipping ...".format(f))
		continue

	read_in = buffer.read()
	buffer.close()

	read_in = read_in.replace("\r\n", "\n").replace("\r", "\n")
	replacement = to_update[f]
	new_lines = []

	version_set = False
	for li in read_in.split("\n"):
		if not version_set:
			if "=" in replacement and li.startswith(replacement):
				key = li.split(" = ")[0]
				li = "{} = {}".format(key, new_version)
				version_set = True
			elif li == replacement:
				li = "v{}".format(new_version)
				version_set = True

		new_lines.append(li)

	write_out = "\n".join(new_lines)
	if write_out == read_in:
		print("no changes for {}, skipping ...".format(f))
		continue

	buffer = codecs.open(f_path, "w", "utf-8")
	if not buffer:
		print("WARNING: could not open {} for writing, skipping ...".format(f))
		continue

	buffer.write("\n".join(new_lines))
	buffer.close()

	print("done")
