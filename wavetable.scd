(
s.waitForBoot({
	~numBuffers = 17;
	~samplesPerCycle = 512;
	~bufs=Buffer.allocConsecutive(~numBuffers, s, ~samplesPerCycle, 1);
	~numBuffers.do({ arg i;
		var filePath = "/home/zns/Documents/supercollisions/plinky"++i++".wav";
		Buffer.read(s,filePath,action:{ |buf|
			buf.postln;
			buf.copyData(~bufs[i],0,0,~samplesPerCycle);
		});

	});
});
)


(
SynthDef("wavetable",{
	arg t_trig2=1, newwave2 = 1, note = 40, db=0, gate= 1;
	var t_trig = Dust.ar(1/4);
	var newwave = Demand.ar(t_trig,0,Drand([0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],inf));
	var wave1 = 0;
	var wave2 = 8;
	var sndwave;
	var freq = (note+Rand(-0.05,0.05)+7).midicps;
	var rate = ~samplesPerCycle * freq / s.sampleRate;
	var snd = Array.fill(~numBuffers,{ arg i;
		PlayBuf.ar(1,~bufs[i],rate:rate, loop:1)
	});
	var toggle = ToggleFF.ar(t_trig);
	wave1 = Latch.ar(newwave,toggle);
	wave2 = Latch.ar(newwave,1-toggle);
	sndwave = SelectX.ar(Lag.ar(1-toggle,2),[Select.ar(wave1,snd),Select.ar(wave2,snd)]);
	sndwave = LPF.ar(sndwave,Clip.kr(freq*LFNoise2.kr(1/3).range(2,5),30,12000));
	sndwave = Pan2.ar(sndwave,LFNoise2.kr(1/3,0.25)) * 24.neg.dbamp * db.dbamp;
	sndwave = sndwave * EnvGen.ar(Env.adsr(Rand(1,2),Rand(1,2),Rand(0.7,1),Rand(1,3)),gate,doneAction:2);
	Out.ar(0,sndwave);
}).add;
SynthDef("out",{
	var snd = In.ar(0,2);
	var sndr = Fverb.ar(snd[0],snd[1],200,
		tail_density:LFNoise2.kr(1/3).range(50,95),
		decay: LFNoise2.kr(1/3).range(50,95),
		damping: LFNoise2.kr(1/3).range(5500,7500),
	);
	snd = SelectX.ar(LFNoise2.kr(1/3).range(0.5,0.7),[snd,sndr]);
	snd = AnalogTape.ar(snd,0.9,0.9,0.7,2);
	ReplaceOut.ar(0,snd);
}).add;
)

(
Routine{
	Synth.tail(s,"out");
	s.sync;
	~chords=[[0,4,7],[-1,4,7],[-1,2,7],[-3,2,4]];
	~root = 48;
	~synths=Dictionary.new();
	inf.do({ arg i;
		i.postln;
		~chord = ~chords[i.mod(~chords.size)];
		~chord.postln;
		~synths.keysValuesDo({ arg k,v;
			if (v.notNil,{
				v.set(\gate,0);
			});
		});
		~synths.put(0,Synth.head(s,"wavetable",[\note,~root+~chord[0]-24,\db,4]));
		~chord.do({arg v;
			~synths.put(v,Synth.head(s,"wavetable",[\note,~root+v]));
			~synths.put(v+100,Synth.head(s,"wavetable",[\note,~root+v+12,\db,-8]));
			~synths.put(v+10000,Synth.head(s,"wavetable",[\note,~root+v+24,\db,-24]));
		});
		12.wait;
	});
}.play;
)

(
{
	var t_trig = Impulse.ar(440/7);
	var newwave = Demand.ar(t_trig,0,Dseq([0,16,0],inf));
	var wave1 = 0;
	var wave2 = 0;
	var sndwave;
	var freq = 440;
	var rate = ~samplesPerCycle * freq / s.sampleRate;
	var snd = Array.fill(~numBuffers,{ arg i;
		PlayBuf.ar(1,~bufs[i],rate:rate, loop:1)
	});
	var toggle = ToggleFF.ar(t_trig);
	wave1 = Latch.ar(newwave,toggle);
	wave2 = Latch.ar(newwave,1-toggle);
	sndwave = SelectX.ar(Lag.ar(1-toggle,3/freq),[Select.ar(wave1,snd),Select.ar(wave2,snd)]);
	sndwave = LPF.ar(sndwave,Clip.kr(freq*4,30,12000));
	// [wave1,wave2,1-toggle,sndwave]
	[sndwave]

}.plot(20/440)
)