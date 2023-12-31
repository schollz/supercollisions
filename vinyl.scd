b=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/synth_dm_bpm130.flac");
c=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/vinyl2.wav");

(
{
	var snd = PlayBuf.ar(2,b,loop:2);
	var sndo = snd;
	snd = snd + PlayBuf.ar(2,c,loop:2);
	snd = Limiter.ar(Compander.ar(snd,snd,0.5,1.0,0.1,0.1,1,2),dur:0.0008);
	snd = DelayC.ar(snd,0.01,VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,0.01));
	snd = HPF.ar(snd,400);
	snd = BLowPass.ar(snd,1200);
	snd = AnalogChew.ar(snd,0.4,0.4,0.4);
	snd = AnalogTape.ar(snd,0.9,0.9,0.9,2);
	snd = SelectX.ar(MouseX.kr().poll,[sndo,snd]);
	Out.ar(0,snd);
}.play;
)