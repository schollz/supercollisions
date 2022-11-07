(
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
{
	var snd=PlayBuf.ar(1,b,loop:1);
	var pan=SinOsc.kr(1/7.13,Rand(0,6))/1.5;
	var pan2=SinOsc.kr(1/12.123,Rand(0,6))/1.5;
	var pan3=SinOsc.kr(1/15.12354,Rand(0,6))/1.5;
	var amp=SinOsc.kr(1/17.123,Rand(0,6)).range(0.25,0.75);
	snd=Pan2.ar(snd,0);
	//snd=WhiteNoise.ar(0.1)!2;
	snd=[snd[0],snd[1]];
	snd=[
		LPF.ar(snd[0],LinExp.kr((pan2<0)*pan2.abs,0,1,4000,18000).poll),
		LPF.ar(snd[1],LinExp.kr((pan2>0)*pan2.abs,0,1,4000,18000).poll)
	];
	snd[0]=SelectX.ar(((pan>0)*pan.abs),[snd[0],DelayN.ar(snd[0],0.04,0.04)]);
	snd[1]=SelectX.ar(((pan<0)*pan.abs),[snd[1],DelayN.ar(snd[1],0.04,0.04)]);
	snd=Balance2.ar(snd[0],snd[1],pan3);
	Out.ar(0,snd*amp);
}.play;
)

b.play;