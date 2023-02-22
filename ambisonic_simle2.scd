(
s.waitForBoot({
	a=Ambiaural.new(s);
	a.playFolder(thisProcess.nowExecutingPath.dirname++"/internet_archive_downloads",10);
	// a.play(thisProcess.nowExecutingPath.dirname++"/internet_archive_downloads/aporee_14575_16967/neoscenes20120815174rest.ogg");
	// a.play(thisProcess.nowExecutingPath.dirname++"/internet_archive_downloads/aporee_14203_16535/neoscenes20120717148sq.ogg");
	// a.play(thisProcess.nowExecutingPath.dirname++"/internet_archive_downloads/aporee_1715_2463/forestwalk.ogg");
});
)


(
s.waitForBoot({
	SynthDef("ambi",{
		arg buf;
		var sndl,sndr;
		var snd=PlayBuf.ar(1,buf,loop:1);
		var lr=VarLag.kr(LFNoise0.kr(1/5.0),5.0,warp:\sine);
		var fb=VarLag.kr(LFNoise0.kr(1/5.0),5.0,warp:\sine);
		var pan=lr*0.25;
		var amp=VarLag.kr(LFNoise0.kr(1/5.0),5.0,warp:\sine).range(0,1);
		sndl=snd;
		sndr=snd;
		sndl=LPF.ar(sndl,LinLin.kr(lr,-1,1,135,100).midicps);
		sndr=LPF.ar(sndr,LinLin.kr(lr,-1,1,100,135).midicps);
		sndl=SelectX.ar(((lr>0.1)*lr.abs),[sndl,DelayN.ar(sndl,0.03,Rand(0.0,0.03))]);
		sndr=SelectX.ar(((lr<0.1.neg)*lr.abs),[sndr,DelayN.ar(sndr,0.03,Rand(0.0,0.03))]);
		snd=Balance2.ar(sndl,sndr,pan,amp);
		snd=SelectX.ar(LinExp.kr(fb,1,-1,0.001,0.19),[snd,Fverb.ar(snd[0],snd[1],60,decay:80)]);
		snd=Compander.ar(snd,snd,(fb+1)/2,slopeAbove:0.1,relaxTime:0.01);
		snd=HPF.ar(snd,LinLin.kr(fb,-1,1,20,1000));
		Out.ar(0,snd);
	}).send(s);
	s.sync;
	b = Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/internet_archive_downloads/aporee_1715_2463/forestwalk.ogg",0,-1,1);
	c = Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/internet_archive_downloads/aporee_14203_16535/neoscenes20120717148sq.ogg",0,-1,1);
	~ok = Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/internet_archive_downloads/aporee_14575_16967/neoscenes20120815174rest.ogg",0,-1,1);
	s.sync;
	Synth("ambi",[\buf,b]);
	// Synth("ambi",[\buf,c]);
	// Synth("ambi",[\buf,~ok]);
});
)

(
a = PathName.new(thisProcess.nowExecutingPath.dirname++"/internet_archive_downloads");
a.filesDo({arg file;
	if (file.fullPath.endsWith(".ogg"),{
		file.postln;
	});
});
)

(
[1,2,3,4,5,6,7].scramble.do({ arg v,i;
	if (i<3,{
		[i,v].postln;
	});
})
)