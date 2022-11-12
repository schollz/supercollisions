// adapted from https://sccode.org/1-5fv
// additional UGens needed:
// AnalogTape, LockhartWavefolder and AnalogVintageDistortion are from
// "ported plugins" https://github.com/madskjeldgaard/portedplugins
(
Ndef(\test, {
	var snd,freq=45;
	var noise;
	var snd2, y,z;

	noise = WhiteNoise.ar * LFPulse.kr(freq * [0.5,2],0,0.01).range(0,0.3);
	noise = BPF.ar(noise, LFNoise0.kr([1/5,1/4]).range(1000,8000).lag(1));
	noise = Splay.ar(noise, LFNoise1.ar(1/3).range(-1,1));
	freq = [freq,freq*1.01];
	snd = Pulse.ar(freq);
	snd = snd + Pulse.ar(freq*2.001,LFNoise1.ar(1/3).range(0.01,0.05));
	snd = MoogFF.ar(snd,freq*VarLag.kr(LFNoise0.kr(1/7),7,warp:\sine).range(3,10));
	snd = LeakDC.ar(snd);
	snd = AnalogTape.ar(snd, 0.9, LFNoise1.kr(1/4).range(0,1), 0.5,0,2);
	snd = snd.fold(-0.5,0.9);
	snd = LockhartWavefolder.ar(snd[0] * LFNoise1.kr(1/4).range(1,10), 4) +
	((LockhartWavefolder.ar(snd[1] * LFNoise1.kr(1/4).range(1,10), 4)) * [-1,1]);
	snd = RLPF.ar(snd, LFNoise1.ar(1/4).exprange(200,9000),	LFNoise1.ar(1/3).range(0.1,0.9));
	snd = snd + noise;

	snd = AnalogVintageDistortion.ar(snd,0,1, oversample:3);
	snd = LeakDC.ar(snd);
	snd = snd * EnvGen.ar(Env.new([0,1,1,0],[0.001,1.0+Line.kr(0,5,20),2]),Impulse.kr(1/(6+Line.kr(0,3,20))));
	snd = snd.softclip;
	//snd = JPverb.ar(snd*0.4,1,0.1,10,3);
	snd = Limiter.ar(snd*1, 0.9) * 0.8;
	snd=LPF.ar(snd,(freq[0]*(10+Line.kr(0,30,30)))).tanh;


	snd2=snd;
	snd2=FreeVerb.ar(snd2,room:10);
	snd2 = DelayN.ar(snd2, 0.03, 0.03);
	snd2 = CombN.ar(snd2, 0.1, {Rand(0.01,0.099)}!32, 4);
	snd2 = SplayAz.ar(2, snd2);
	snd2 = LPF.ar(snd2, 1500);
	5.do{snd2 = AllpassN.ar(snd2, 0.1, {Rand(0.01,0.099)}!2, 3)};
	snd2 = LPF.ar(snd2, 1500);
	snd2 = LeakDC.ar(snd2);

	Out.ar(0,SelectX.ar(SinOsc.kr(0.1).range(0.5,0.8),[snd,snd2]).tanh);
}).play
)
