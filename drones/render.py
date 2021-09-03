#!/bin/python3

import os
import glob
import time

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
            f2.write("s.waitForBoot {\n")
            f2.write("""
r = Recorder.new(s);
// record into a flac file
r.recHeaderFormat = "flac";
// default 'float' is incompatible with flac. set to 24bit:
r.recSampleFormat = "int24";
// set very obvious prefix for files
r.filePrefix = """+'"'+fname+'"'+""";
// start recording:
r.record;
""")
            f2.write(data)
            f2.write("Routine{11.wait; s.quit;}.play;}")
        os.system("""docker run -v `pwd`/"""+dirname+""":/data -d sc""")
        time.sleep(60)
