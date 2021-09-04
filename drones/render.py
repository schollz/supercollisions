#!/bin/python3
#
# before rendering, need to build the docker image:
#
#   git clone https://github.com/schollz/supercollider-radio
#   cd supercollider-radio
#   docker build -t sc .
#
# then all files can be rendered with 
#   
#   python3 render.py
# 
# and then converted to wav with
#
#   for i in */*.aiff; do ffmpeg -i "$i" "${i%.*}.wav"; done   
#

import os
import glob
import time
import re

song_time=2 #minutes

song_time=song_time*60-20 #seconds
files=list(glob.glob("*.scd"))
for _, fname in enumerate(files):
    if "template" in fname:
        continue
    with open(fname,"r") as f:
        data=f.read()
        if "seconds" not in data:
            print("NO SECONDS!")
            print(fname)
            raise
        data=data.replace("seconds=60","seconds={}".format(song_time))
        dirname=fname+".render"
        if not os.path.exists(dirname):
            os.makedirs(dirname)
        with open(os.path.join(dirname,fname),"w") as f2:
            f2.write("s.waitForBoot {\n")
            f2.write("""
s.record(duration:"""+str(song_time+20)+""",path:"/data/"""+fname+""".aiff");
""")
            f2.write(data)
            f2.write("Routine{"+str(song_time+22)+".wait; s.quit;}.play;}")
        os.system("""docker run -v `pwd`/"""+dirname+""":/data -d sc""")
        # time.sleep(song_time+24)
