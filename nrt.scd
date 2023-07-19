(
s.waitForBoot({


	SynthDef("0",{
		arg out,buf,start=0,stop=1,xfade=0.05;
		var snd=PlayBuf.ar(
			numChannels:2,
			bufnum:buf,
			rate:1.0,
			trigger:1.0,
			startPos:start*BufFrames.ir(buf),
			loop:1,
		);
		var env=EnvGen.ar(Env.new([1,1,0],[(stop-start)*BufDur.ir(buf),xfade]),doneAction:2);

		Out.ar(out,snd*env);
	}).add;
});
)

(-1).mod(10)