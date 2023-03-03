(
s.waitForBoot{
	var duration=10;
	b=Buffer.alloc(s,s.sampleRate*duration,2);
	s.sync;
	SynthDef("pulse",{
		arg note=72;
		var snd2;
		var amplitude;
		var amplitude2;
		var lfomax=LFNoise2.kr(1).range(0.5,1);
		var lfomin=LFNoise2.kr(1).range(0.7,0.8);
		var freq=LFNoise2.ar(note.midicps).range(note-0.25,note+0.2).midicps;
		var freq2=LFNoise2.ar(note.midicps*0.75).range(note-0.2+0.2,note+0.25+0.2).midicps;
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
			snd=snd+FOS.ar(Saw.ar(freq2,mul:24.neg.dbamp),0.6921,0,0.3079);
			snd=snd+FOS.ar(WhiteNoise.ar(54.neg.dbamp),0.6921,0,0.3079);

			snd=snd*EnvGen.ar(Env.new([lfomin,lfomax,lfomax,lfomin,lfomin,lfomin],[0.07,0.07,0.01,0.1,0.03],'lin',4,0),timeScale:LFNoise0.kr(10).range(0.5,4));
			snd=snd*LFNoise1.ar(4).range(1.neg.dbamp,1.dbamp);
			snd=LeakDC.ar(snd);

			snd=(snd*(6.dbamp)).tanh;
			
			// OnePoleHPF 20
			snd=FOS.ar(snd,0.9567,0,0.0433.neg);
			// OnePoleHPF 30
			snd=FOS.ar(snd,0.9566,0,0.0434.neg);
			// OnePoleHPF 100
			snd=FOS.ar(snd,0.9562,0,0.0438.neg);
			snd=BLowShelf.ar(snd,100,1.0,-12);
			// 6k OP LPF
			snd=FOS.ar(snd,0.5441,0,0.4559); 
			// 9k OP LPF
			snd=FOS.ar(snd,0.6921,0,0.3079); 

			snd=LPF.ar(snd,19000);
		
			snd=snd*6.neg.dbamp;
			snd=Select.ar(snd>0,{
				[snd*LFNoise1.ar(1).range(3.neg.dbamp,3),snd*LFNoise1.ar(10).range(6.neg.dbamp,6.dbamp)]
			});
			snd=HPF.ar(snd,30);
			snd=HPF.ar(snd,6);
			snd;
		};
		snd2=x.value(SinOsc.kr(3.5).range(0,1))/6;
		Out.ar(0,snd2!2);
	}).add;
	{
		var in=In.ar(0,2);
		RecordBuf.ar(in,b,doneAction:2);
		ReplaceOut.ar(0,Silent.ar());
	}.play;
	s.sync;
	Synth("pulse",[\note,72]);
	Routine {
		b.duration.wait;
		b.write("/tmp/mine.wav","wav","int16");
		s.sync;
		0.exit;
	}.play;
}
)
