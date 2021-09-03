#!/bin/python3

import os
import glob
import time

if not os.path.exists("recordings"):
	os.makedirs("recordings")

files=list(glob.glob("*.scd"))
for _, fname in enumerate(files):
	if "template" in fname:
		continue
	with open(fname,"r") as f:
		data=f.read()
		dirname=fname+".sc"
		if not os.path.exists(dirname):
			os.makedirs(dirname)
		os.system("""docker run -v `pwd`/"""+dirname+""":/data -v `pwd`/recordings:/root/.local/share/SuperCollider/Recordings -d sc""")
		break
	break