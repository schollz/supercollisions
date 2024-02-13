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

b[0].query