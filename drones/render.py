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
		with open(os.path.join(dirname,fname),"w") as f2:
			f2.write("s.waitForBoot { s.record(duration:1800);")
			f2.write(data)
			f2.write("}")
		os.system("""docker run -v `pwd`/"""+dirname+""":/data -v `pwd`/recordings:/root/.local/share/SuperCollider/Recordings -d sc""")
		break
	break