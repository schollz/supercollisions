(
SynthDef(\xfader, {
	|out=0, buf=0, start=0, end=1, rate=1, fade=0.05, gate=1|
	var frames = BufFrames.ir(buf);
	var rateScale = BufRateScale.ir(buf);
	var isReverse = start > end;
	var loopStart = min(start, end) * frames;
	var loopEnd   = max(start, end) * frames;
	var loopSize  = loopEnd - loopStart;
	var effectiveRate = rate * rateScale * Select.kr(isReverse, [1, -1]);
	var phasor, pos1, pos2, toggle, fadeCtrl, sig1, sig2;
	var env = EnvGen.ar(Env.asr(fade,1.0,fade),gate,doneAction:2);
	var snd, snd2;

	// Phasor over 2× loop size
	phasor = Phasor.ar(
		trig: 0,
		rate: effectiveRate,
		start: loopStart,
		end: loopStart + (loopSize * 2),
		resetPos: loopStart
	);

	// Wrap across whole buffer
	pos1 = Wrap.ar(phasor, 0, frames);
	pos2 = Wrap.ar(phasor - loopSize, 0, frames);

	// Toggle when passing half point
	toggle = Changed.ar(phasor >= (loopStart + loopSize));

	// Linear fading using VarLag
	fadeCtrl = VarLag.ar(ToggleFF.ar(toggle), time: fade, warp: \linear)
	.linlin(0, 1, -1, 1);

	// Stereo BufRd (2 channels), one buffer
	sig1 = BufRd.ar(2, buf, pos1, loop: 0);
	sig2 = BufRd.ar(2, buf, pos2, loop: 0);

	snd = XFade2.ar(sig1, sig2, fadeCtrl);

	// drive
	snd = SineShaper.ar(snd*MouseY.kr(0,4),MouseX.kr(0,1));

	// XFade2 crossfade
	Out.ar(out, snd);
}).add;
)

(
a=Buffer.read(s,"/home/zns/Documents/supercollisions/HGAT_120_alt_drum_loop_granular_key_bpm120_beats16_.flac");
c=Buffer.read(s,"/home/zns/Documents/supercollisions/ff_ma_130_synth_loop_distorted_Cmin_key_bpm200_130_beats32_.flac");
e=Buffer.read(s,"/home/zns/Documents/supercollisions/SO_DRR_104_choir_Epic_Cm_key_bpm200_104_beats16_.flac");
)
(
s.bind {
	b = Synth(\xfader, [\buf, a, \start, 0.0, \end, 0.25, \fade, 0.1, \rate, 130/120]);
	g = Synth(\xfader, [\buf, a, \start, 0.5, \end, 1.0, \fade, 0.2, \rate, 130/120/2]);
};
)
(
b.set(\gate,0);
d.set(\gate,0);
f.set(\gate,0);
g.set(\gate,0);
b=Synth(\xfader,[\buf,a,\start,0.125,\end,0.75,\fade,0.1,\rate,130/120]);
g=Synth(\xfader,[\buf,a,\start,0,\end,0.75,\fade,0.05,\rate,130/120/2]);
d=Synth(\xfader,[\buf,c,\start,0+0.25,\end,0.5+0.25,\fade,0.05,\rate,130/100]);
f=Synth(\xfader,[\buf,e,\start,0.0,\end,1.0,\fade,1,\rate,130/200]);
)

b.set(\start,0.0,\end,0.25);


b=Synth(\xfadeLooper,[\buf,a,\loopStart,0,\loopEnd,0.5,\fadeTime,1.0,\rate,175/120]);
d=Synth(\xfadeLooper,[\buf,c,\loopStart,0,\loopEnd,0.5,\fadeTime,1.0,\rate,175/100]);
f=Synth(\xfadeLooper,[\buf,e,\loopStart,0,\loopEnd,0.5,\fadeTime,1.0,\rate,175/200]);
