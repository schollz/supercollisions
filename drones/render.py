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
        dirname=fname+".render"
        if not os.path.exists(dirname):
            os.makedirs(dirname)
        with open(os.path.join(dirname,fname),"w") as f2:
            f2.write("s.waitForBoot {\ns.record(path:'{}',duration:10);\n".format("/data/"+fname+".aiff"))
            f2.write(data)
            f2.write("Routine{11.wait; s.quit;}.play;}")
        os.system("""docker run -v `pwd`/"""+dirname+""":/data -d sc""")
        time.sleep(60)
