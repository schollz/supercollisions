(
s.waitForBoot{
	b=Buffer.alloc(s,512,1);
	b.sine2([2],[0.5],false);
	s.record;
	{
		arg note=72;
		var snd2;
		var lfomax=2;
		var freq=LFNoise2.kr(1).range(note-0.05,note+0.05).midicps;
		var x={
			arg g2phase=0;
			var snd;
			var startphase=1.neg;
			var width=0.15;
			var g1height=1;
			var g2height=LinLin.kr(g2phase,0,1,0.75,1)*SinOsc.kr(3.9).range(0,1);
			var g1=LFGauss.ar(
				duration:1/freq,
				width:width,
				iphase:startphase,
			)*1.neg*g1height;
			var g2=LFGauss.ar(
				duration:1/freq,
				width:width,
				iphase:startphase+g2phase,
			)*1.neg*g2height;
			snd=g1+g2;
			// snd=snd+SinOsc.ar(freq,pi/4*1,mul:0.1.neg*(1-g2phase));
			snd=LeakDC.ar(snd,0.995);
			snd=snd*EnvGen.ar(Env.new([1,lfomax,lfomax,1,1,1],[0.07,0.07,0.01,0.1,0.03],'lin',4,0));
			snd=snd.tanh/lfomax;
			snd=LPF.ar(snd,6*freq);
			snd/2;
		};
		snd2=x.value(SinOsc.kr(3.0).range(0,1));
		Out.ar(0,snd2!2);
	}.play;
	Routine {
		2.wait;
		s.stopRecording;
	}.play;
}
)



({EnvGen.ar(Env.new([1,2,2,1,1,1],[0.07,0.07,0.01,0.1,0.03],'lin',4,0),timeScale:0.1)}.plot(0.1))