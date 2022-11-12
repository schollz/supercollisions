(
s.waitForBoot({
	Routine {
		"starting".postln;
		o=Ouroboro.new(s);
		1.wait;
		o.record(111,1.2345,0.2345,0,{
			arg buf;
			["DONE"+buf.duration].postln;
		});

	}.play;
})
)



		2.do({
			arg n;
			var ch=n+1
			SynthDef("defPlay"++ch,{
				arg id,bufnum;
				var snd=PlayBuf.ar
			});
		});



false.asInteger
(
o.record(111,3,0.1,2,{
	arg buf;
	b=buf;
});
o.record(113,3,0.1,2,{
	arg buf;
	b=buf;
});
)
b.play;
b.plot;

(
s.waitForBoot({
	Routine {
		"starting".postln;
		o=Ouroboro.new(s);
		1.wait;
		o.record(111,1,1,0);
		0.5.wait;
		o.stop(111);
	}.play;
})
)
b.numChannels
b=Buffer.new(s,1400,2);
b