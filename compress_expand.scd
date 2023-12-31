(
s.waitForBoot({
	var bufs;
	var n, mu, unit, expandCurve, compressCurve;
	n = 512*2;
	mu = 255*2;
	unit = Array.fill(n, {|i| i.linlin(0, n-1, -1, 1) });
	compressCurve = unit.collect({ |x|
		x.sign * log(1 + mu * x.abs) / log(1 + mu);
	});
	expandCurve = unit.collect({ |y|
		y.sign / mu * ((1+mu)**(y.abs) - 1);
	});
	bufs = Dictionary.new();
	bufs.put("compress",Buffer.loadCollection(s,Signal.newFrom(compressCurve).asWavetableNoWrap));
	bufs.put("expand",Buffer.loadCollection(s,Signal.newFrom(expandCurve).asWavetableNoWrap));

	SynthDef("play",{
		arg buf, bufExpand, bufCompress;
		var snd,sndE,sndC,sndT;
		snd = PlayBuf.ar(2,buf,loop:2);
		sndC = Shaper.ar(bufCompress,snd);
		sndE = Shaper.ar(bufExpand,snd);
		sndT = SelectX.ar(snd.abs>MouseY.kr(),[sndE,sndC]);
		snd = SelectX.ar(MouseX.kr,[snd,sndT]);
		Out.ar(0,snd);
	}).send(s);

	Routine {
		b=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/PMA_03_Vocal_Atmosphere_Dmin_110Bpm_keyDmin_bpm110_beats16_.flac");
		s.sync;
		Synth("play",[
			buf:b,
			bufExpand: bufs.at("expand"),
			bufCompress: bufs.at("compress"),
		]);
	}.play;
})
)