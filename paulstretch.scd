(
SynthDef(\paulstretchMono, { |out = 0, bufnum, envBufnum, pan = 0, stretch = 2000, window = 0.25, amp = 1|
	// Paulstretch for SuperCollider
	// Based on the Paul's Extreme Sound Stretch algorithm by Nasca Octavian PAUL
	// https://github.com/paulnasca/paulstretch_python/blob/master/paulstretch_steps.png
	//
	// By Jean-Philippe Drecourt
	// http://drecourt.com
	// April 2020
	//
	// Arguments:
	// out: output bus (stereo output)
	// bufnum: the sound buffer. Must be Mono. (Use 2 instances with Buffer.readChannel for stereo)
	// envBufnum: The grain envelope buffer created as follows:
	//// envBuf = Buffer.alloc(s, s.sampleRate, 1);
	//// envSignal = Signal.newClear(s.sampleRate).waveFill({|x| (1 - x.pow(2)).pow(1.25)}, -1.0, 1.0);
	//// envBuf.loadCollection(envSignal);
	// pan: Equal power panning, useful for stereo use.
	// stretch: stretch factor (modulatable)
	// window: the suggested grain size, will be resized to closest fft window size
	// amp: amplification
	var trigPeriod, sig, chain, trig, pos, fftSize;
	// Calculating fft buffer size according to suggested window size
	fftSize = 2**floor(log2(window*SampleRate.ir));
	// Grain parameters
	// The grain is the exact length of the FFT window
	trigPeriod = fftSize/SampleRate.ir;
	trig = Impulse.ar(1/trigPeriod);
	pos = Demand.ar(trig, 0, demandUGens: 0.05+Dseries(0, trigPeriod/stretch)).poll;
	// Extraction of 2 consecutive grains
	// Both grains need to be treated together for superposition afterwards
	sig = [GrainBuf.ar(1, trig, trigPeriod, bufnum, 1, pos, envbufnum: envBufnum),
		GrainBuf.ar(1, trig, trigPeriod, bufnum, 1, pos + (trigPeriod/(2*stretch)), envbufnum: envBufnum)]*amp;
	// FFT magic
	sig = sig.collect({ |item, i|
		chain = FFT(LocalBuf(fftSize), item, hop: 1.0, wintype: -1);
		// PV_Diffuser is only active if its trigger is 1
		// And it needs to be reset for each grain to get the smooth envelope
		chain = PV_Diffuser(chain, 1 - trig);
		item = IFFT(chain, wintype: -1);
	});
	// Reapply the grain envelope because the FFT phase randomization removes it
	sig = sig*PlayBuf.ar(1, envBufnum, 1/(trigPeriod), loop:1);
	// Delay second grain by half a grain length for superposition
	sig[1] = DelayL.ar(sig[1], trigPeriod/2, trigPeriod/2);
	// Panned output
	Out.ar(out, Pan2.ar(Mix.new(sig), pan));
}).add;
SynthDef("out",{
	arg amp=1.0;
	var snd=In.ar(0,2);
	snd=HPF.ar(snd,30);
	snd=LPF.ar(snd,1000);
	snd=Limiter.ar(snd,0.5);
	snd=AnalogTape.ar(snd,0.9,0.9,0.8,2);
	snd=SelectX.ar(LFNoise2.kr(1/4).range(0.1,0.4),[snd,Fverb.ar(snd[0],snd[1],50,decay:LFNoise2.kr(1/4).range(70,90))]);
	ReplaceOut.ar(0,snd*Lag.kr(amp)*EnvGen.ar(Env.new([0,1],[3])));
}).send(s);

)

// Example
(
var envBuf, envSignal, wav;
var stretch = 1000;
s.record;
wav="/home/zns/Documents/norns-docker/dust/audio/windchimes.wav";
wav="/home/zns/Documents/supercollisions/whale.wav";
wav="/home/zns/Downloads/seinfield.wav";
b=Buffer.read(s,wav,0,s.sampleRate*3);
Buffer.readChannel(s, wav,0,-1,0,{
	arg buffer1;
	Buffer.readChannel(s, wav,0,-1,1,{
		arg buffer2;
		Routine {
			envBuf = Buffer.alloc(s, s.sampleRate, 1);
			envSignal = Signal.newClear(s.sampleRate).waveFill({|x| (1 - x.pow(2)).pow(1.25)}, -1.0, 1.0);
			envBuf.loadCollection(envSignal);
			s.sync();
			b.play;
			b.duration.wait;
			// Runs indefinitely
			0.1.wait;
			Synth.tail(s,"out");
			0.1.wait;
			Synth.head(s,\paulstretchMono, [\stretch, stretch, \bufnum, buffer1.bufnum, \envBufnum, envBuf.bufnum,\pan,-1]);
			Synth.head(s,\paulstretchMono, [\stretch, stretch, \bufnum, buffer2.bufnum, \envBufnum, envBuf.bufnum,\pan,1]);
		}.play;
	});
});
)
