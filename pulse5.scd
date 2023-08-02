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
		var mod = 0;// SinOsc.ar((note+12).midicps, freq* 1.5 * LFNoise1.kr(1.reciprocal).abs);
		var x={
			arg g2phase=0,freqmod=0;
			var snd;
			var startphase=1.neg;
			var width=0.15;
			var g1height=1;
			var g2height=LinLin.kr(g2phase,0,1,0.75,1);
			var g1=LFGauss.ar(
				duration:1/(freq+freqmod),
				width:width,
				iphase:startphase,
			)*1.neg*g1height;
			var g2=LFGauss.ar(
				duration:1/(freq+freqmod),
				width:width,
				iphase:startphase+g2phase,
			)*1.neg*g2height;
			snd=g1+g2;


			// add some beating
			snd=snd+SinOsc.ar(freq+LFNoise2.kr(1).range(2,4),mul:0.05);

			// add some higher harmonics
			// snd=snd+
			// FOS.ar(Saw.ar(freq/2),
			// DC.kr(1-exp(-2.0*3.14159265*freq*2/s.sampleRate)),0,DC.kr(exp(-2.0*3.14159265*1000.0/s.sampleRate)));



			snd=snd*Lag.kr(ToggleFF.kr(Dust.kr(3),0.2)).range(12.neg.dbamp,0.dbamp);

			snd=LeakDC.ar(snd);

			snd=snd*Lag.kr(Trig.kr(Dust.kr(3)).range(0.dbamp,6.dbamp));

			snd=(snd*2.dbamp).tanh;

			// OnePoleHPF 20
			snd=FOS.ar(snd,0.9567,0,0.0433.neg);
			// OnePoleHPF 30
			snd=FOS.ar(snd,0.9566,0,0.0434.neg);
			// OnePoleHPF 100
			snd=FOS.ar(snd,0.9562,0,0.0438.neg);
			// 6k OP LPF
			snd=FOS.ar(snd,DC.kr(1-exp(-2.0*3.14159265*7000.0/s.sampleRate)),0,DC.kr(exp(-2.0*3.14159265*6000.0/s.sampleRate)));
			// 9k OP LPF
			snd=FOS.ar(snd,DC.kr(1-exp(-2.0*3.14159265*9000.0/s.sampleRate)),0,DC.kr(exp(-2.0*3.14159265*9000.0/s.sampleRate)));


			snd=LPF.ar(snd,19000);

			snd=snd*6.neg.dbamp;
			snd=HPF.ar(snd,30);
			snd=HPF.ar(snd,6);
			snd;
		};
		snd2=x.value(SinOsc.ar(note.midicps/5))/6;
		// snd2=x.value(LFNoise2.kr(3.0).range(0,1))/6;
		// snd2=snd2+(x.value(0)*SinOsc.kr(1/3,mul:0.5).abs);
		Out.ar(0,snd2!2);
	}).add;
	{
		var snd=In.ar(0,2);
		var random_modulation={LFNoise2.kr(1/4)}!4;
		// RecordBuf.ar(in,b,doneAction:2);
		snd=SelectX.ar(random_modulation[0].range(0.1,0.5),[snd,Fverb.ar(snd[0],snd[1],50,decay:random_modulation[1].range(70,90))]);
		ReplaceOut.ar(0,snd);
	}.play;
	s.sync;
	Synth("pulse",[\note,72]);
	Synth("pulse",[\note,72+3]);
	Synth("pulse",[\note,72+7]);
	// Routine {
	// 	b.duration.wait;
	// 	b.write("/tmp/mine.wav","wav","int16");
	// 	s.sync;
	// 	0.exit;
	// }.play;
}
)
