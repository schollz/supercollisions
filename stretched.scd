// 926  sox amenbreak_bpm136.wav 1.flac
// 928  sox amenbreak_bpm136.wav 2.flac tempo -s 0.75
// 929  sox amenbreak_bpm136.wav 3.flac tempo -s 0.5
// 930  sox amenbreak_bpm136.wav 4.flac tempo -s 0.25
// 932  sox amenbreak_bpm136.wav 5.flac tempo -s 0.125

(
SynthDef("xPlay",{
	arg buf1,buf2,buf3,buf4,buf5,slow=0;
	var pos,snd1,snd2,snd3,snd4,snd5,snd,sel;
	pos=Phasor.ar(1,BufRateScale.kr(buf1),end:BufFrames.kr(buf1)*20).poll;
	snd1=BufRd.ar(2,buf1,pos.mod(BufFrames.kr(buf1)),1.0,4);
	snd2=BufRd.ar(2,buf2,pos.mod(BufFrames.kr(buf2)),1.0,1);
	snd3=BufRd.ar(2,buf3,pos.mod(BufFrames.kr(buf3)),1.0,1);
	snd4=BufRd.ar(2,buf4,pos.mod(BufFrames.kr(buf4)),1.0,1);
	snd5=BufRd.ar(2,buf5,pos.mod(BufFrames.kr(buf5)),1.0,1);
	snd=SelectX.ar(Lag.kr(Select.kr(MouseX.kr(-0.2,1.2)*4.999,[0,1,2,3,4]),0.2).poll,[snd1,snd2,snd3,snd4,snd5],0);
	Out.ar(0,snd);
}).add;
)


a=Buffer.read(Server.default, thisProcess.nowExecutingPath.dirname++"/1.flac");
b=Buffer.read(Server.default, thisProcess.nowExecutingPath.dirname++"/2.flac");
c=Buffer.read(Server.default, thisProcess.nowExecutingPath.dirname++"/3.flac");
d=Buffer.read(Server.default, thisProcess.nowExecutingPath.dirname++"/4.flac");
e=Buffer.read(Server.default, thisProcess.nowExecutingPath.dirname++"/5.flac");

e.play;
x=Synth("xPlay",[\buf1,a,\buf2,b,\buf3,c,\buf4,d,\buf5,e]);
x.set(\slow,0);
x.set(\slow,0.2);
x.set(\slow,0.5);
x.set(\slow,0.75);
x.set(\slow,1);

b.play;
48000*60