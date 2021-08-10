(
SynthDef("upload",{
    SendTrig.kr(Impulse.kr(1.0),0,1);
}).add;

// register to receive this message
~o1 = OSCFunc({ arg msg, time;
    [time, msg].postln;
    // send message to upload
    NetAddr("127.0.0.1",8765).sendMsg("/up","C:\\Users\\zacks\\Downloads\\up.wav");
},'/tr', s.addr);
~o2 = OSCFunc({ arg msg, time;
    [time, msg].postln;
    // message is received to load new file
},'/down');
)


Synth("upload");



























// this doens't really work...
(
Routine {
var p, l;
    p = Pipe.argv(["ping","sourceforge.net"], "r");    // list directory contents in long format
l = p.getLine;                    // get the first line
while({l.notNil}, {l.postln; l = p.getLine; });    // post until l = nil
p.close;                    // close the pipe to avoid that nasty buildup
    "done".postln;
}.play;
)

(
Routine {
var p, l;
	"uploading".postln;
    p = Pipe.argv(["Invoke-WebRequest","-InFile","C:\Users\zacks\Desktop\temp\hello.txt","-uri","https://duct.schollz.com/zz","-Method","Post"], "r");
    l = p.getLine;
    while({l.notNil}, {l.postln; l = p.getLine; });    // post until l = nil
    p.close;                    // close the pipe to avoid that nasty buildup
    "done".postln;
}.play;
Routine {
var p, l;
	"downloading".postln;
    1.wait;
    p = Pipe.argv(["Invoke-WebRequest","-uri","https://duct.schollz.com/zz","-Method","Get"], "r");    // list directory contents in long format
    l = p.getLine;                    // get the first line
    while({l.notNil}, {l.postln; l = p.getLine; });    // post until l = nil
    p.close;                    // close the pipe to avoid that nasty buildup
    "done".postln;
}.play;
)