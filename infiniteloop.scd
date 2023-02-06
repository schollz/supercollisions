(
s.waitForBoot({
	SynthDef("loop",{
		arg buf;
		var snd=PlayBuf.ar(2,buf,BufRateScale.ir(buf))*EnvGen.ar(Env.new([1,1,0],[4,0.1]));
		snd=snd+LocalIn.ar(2);
		snd=CombC.ar(snd,0.5,LFNoise2.kr(0.3).range(0.2,0.5),LFNoise2.kr(0.3).range(0.1,2));
		snd=CombC.ar(snd,0.5,LFNoise2.kr(0.3).range(0.2,0.5),LFNoise2.kr(0.3).range(0.1,2));
		snd=CombC.ar(snd,0.5,LFNoise2.kr(0.3).range(0.2,0.5),LFNoise2.kr(0.3).range(0.1,2));
		snd=CombC.ar(snd,0.5,LFNoise2.kr(0.3).range(0.2,0.5),LFNoise2.kr(0.3).range(0.1,2));
		snd=CombC.ar(snd,0.5,LFNoise2.kr(0.3).range(0.2,0.5),LFNoise2.kr(0.3).range(0.1,2));
		snd=CombC.ar(snd,0.5,LFNoise2.kr(0.3).range(0.2,0.5),LFNoise2.kr(0.3).range(0.1,2));
		snd=CombC.ar(snd,0.5,LFNoise2.kr(0.3).range(0.2,0.5),LFNoise2.kr(0.3).range(0.1,2));
		snd=CombC.ar(snd,0.5,LFNoise2.kr(0.3).range(0.2,0.5),LFNoise2.kr(0.3).range(0.1,2));
		LocalOut.ar(snd);
		Out.ar(0,snd);
	}).send(s);
	s.sync;
	b = Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/starlids.wav");
	s.sync;
	Synth("loop",[\buf,b]);
});
)