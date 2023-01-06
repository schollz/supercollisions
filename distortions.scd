(
var s=Server.default;
s.waitForBoot({

	// from Ezra: https://github.com/norns-study-group/pirate-radio/blame/159ac8d17df0935db8b53e3acaa1d7764da8aa21/supercollider/classes/PirateRadio.sc#L792-L809
	var n = 512*2;
	var mu = 255*2;
	var unit = Array.fill(n, {|i| i.linlin(0, n-1, -1, 1) });
	var compressCurve = unit.collect({ |x|
		x.sign * log(1 + mu * x.abs) / log(1 + mu);
	});
	var expandCurve = unit.collect({ |y|
		y.sign / mu * ((1+mu)**(y.abs) - 1);
	});
	~expand = Buffer.loadCollection(s,Signal.newFrom(expandCurve).asWavetableNoWrap);
	~compress = Buffer.loadCollection(s,Signal.newFrom(compressCurve).asWavetableNoWrap);

	// my favorite saturation curve
	~saturation = Buffer.alloc(s,1024,1);
	~saturation.sine2([2],[0.5],false);


	// take it for a TEST DRIVE
	SynthDef("drive",{
		arg bufTest,bufSaturation,bufExpand,bufCompress,
		sat=0,expa=0,com=0;

		var snd=PlayBuf.ar(1,bufTest,loop:1);
		var x=MouseX.kr().poll;
		var y=MouseY.kr(-16,16).poll.dbamp;

		// sinoid drive
		snd=SelectX.ar(Lag.kr(sat)*x,[snd,Shaper.ar(bufSaturation,snd*y)]);

		// compress curve
		snd=SelectX.ar(Lag.kr(com)*x,[snd,Shaper.ar(bufCompress,snd*y)]);

		// expand cruve
		snd=SelectX.ar(Lag.kr(expa)*x,[snd,Shaper.ar(bufExpand,snd*y)]);

		Out.ar(0,snd!2);
	}).send(s);

});
)

~testBuf = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

(
// saturation
~player=Synth.new("drive",[
	bufTest:~testBuf,
	bufSaturation:~saturation,
	bufExpand:~expand,
	bufCompress:~compress,
	sat:1,
	expa:0,
	com:0,
]);
)

(
// compression
~player=Synth.new("drive",[
	bufTest:~testBuf,
	bufSaturation:~saturation,
	bufExpand:~expand,
	bufCompress:~compress,
	sat:0,
	com:1,
	expa:0,
]);
)

(
// expander
~player=Synth.new("drive",[
	bufTest:~testBuf,
	bufSaturation:~saturation,
	bufExpand:~expand,
	bufCompress:~compress,
	sat:0,
	com:0,
	expa:1,
]);
)