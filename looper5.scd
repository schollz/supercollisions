(
SynthDef(\xfadeLooper_simple, {
    |buf=0, rate=1, loopStart=0, loopEnd=1, fadeTime=0.1, amp=1, gate=1|
    var sr, bufFrames, startFrame, endFrame, rateset, fadeFrames, fadeFrameBoundary;
    var phase, phaseA, phaseB, lastPhase, loopTrig;
    var activeHead, sig1, sig2, xfade;
    var snd, trigA, trigB;
    var feedbackIn;

    sr = BufSampleRate.ir(buf);
    bufFrames = BufFrames.ir(buf);
    startFrame = loopStart * bufFrames;
    endFrame = loopEnd * bufFrames;
    rateset = rate * BufRateScale.ir(buf);
    fadeFrames = fadeTime * sr * rate;
    fadeFrameBoundary = endFrame - fadeFrames;

    // [activeHead, loopTrig from previous sample]
    feedbackIn = LocalIn.ar(2);
    activeHead = feedbackIn[0];
    loopTrig = feedbackIn[1];

    // Reset the INACTIVE head when loopTrig fires
	// trigA is activeHead == 0
	// trigB is activeHead == 1
    trigA = loopTrig * (1 - activeHead);
    trigB = loopTrig  * activeHead;

    phaseA = Phasor.ar(
        trig: trigA.poll(label:"trigA"),
        rate: rateset,
        start: startFrame,
        end: endFrame,
    );

    phaseB = Phasor.ar(
        trig: trigB.poll(label:"trigB"),
        rate: rateset,
        start: startFrame,
        end: endFrame.poll(label:"endFrame"),
    );

    phase = Select.ar(activeHead, [phaseA, phaseB]);
    lastPhase = Delay1.ar(phase);

    loopTrig = (phase >= fadeFrameBoundary.poll(label:"fadeFrameBoundary")) * (lastPhase < fadeFrameBoundary);

    LocalOut.ar([ToggleFF.ar(loopTrig.poll(label:"loopTrig")), loopTrig]);

    sig1 = BufRd.ar(2, buf, phaseA.poll(label:"phaseA"));
    sig2 = BufRd.ar(2, buf, phaseB.poll(label:"phaseB"));

	xfade = VarLag.ar(activeHead.poll(label:"activeHead"), time:fadeTime,warp:\linear);
	snd = XFade2.ar(sig1,sig2,(2 * xfade.poll(label:"xfade")) - 1);

	snd = snd * EnvGen.ar(Env.asr(fadeTime,1.0,fadeTime),gate,doneAction:2);

    Out.ar(0, snd * amp);
}).add;
)




(
a=Buffer.read(s,"/home/zns/Documents/supercollisions/HGAT_120_alt_drum_loop_granular_key_bpm120_beats16_.flac");
c=Buffer.read(s,"/home/zns/Documents/supercollisions/ff_ma_130_synth_loop_distorted_Cmin_key_bpm200_130_beats32_.flac");
e=Buffer.read(s,"/home/zns/Documents/supercollisions/SO_DRR_104_choir_Epic_Cm_key_bpm200_104_beats16_.flac");
)
(
b.set(\gate,0);
d.set(\gate,0);
f.set(\gate,0);
b=Synth(\xfadeLooper_simple,[\buf,a,\loopStart,0.25,\loopEnd,0.25+0.5,\fadeTime,0.05,\rate,130/120]);
d=Synth(\xfadeLooper_simple,[\buf,c,\loopStart,0+0.25,\loopEnd,0.5+0.25,\fadeTime,0.05,\rate,130/100]);
f=Synth(\xfadeLooper_simple,[\buf,e,\loopStart,0.5,\loopEnd,0.5+0.125,\fadeTime,0.05,\rate,130/200]);
)



b=Synth(\xfadeLooper,[\buf,a,\loopStart,0,\loopEnd,0.5,\fadeTime,1.0,\rate,175/120]);
d=Synth(\xfadeLooper,[\buf,c,\loopStart,0,\loopEnd,0.5,\fadeTime,1.0,\rate,175/100]);
f=Synth(\xfadeLooper,[\buf,e,\loopStart,0,\loopEnd,0.5,\fadeTime,1.0,\rate,175/200]);
