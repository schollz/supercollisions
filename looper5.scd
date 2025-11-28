(
SynthDef(\xfadeLooper, {
    |buf=0, rate=1.0, loopStart=0.0, loopEnd=1.0, fadeTime=0.1,
     gate=1, amp=1, attack=0.1, release=0.1|

    var rateset, sr, bufFrames, startFrame, endFrame, fadeFrames;
    var phaseA, phaseB, sigA, sigB, fadePos, xfade, env;
    var isReverse, jumpTrig, fadeStart, fadeEnd;

    rateset = rate * BufRateScale.ir(buf);
    sr = BufSampleRate.ir(buf);
    bufFrames = BufFrames.ir(buf);

    // Convert loop points (fractions) into buffer frames
    startFrame = loopStart * bufFrames;
    endFrame   = loopEnd * bufFrames;

    // Detect reverse if loopStart > loopEnd
    isReverse = (loopStart > loopEnd);

    // Reverse playback if needed
    rateset = Select.kr(isReverse, [rateset, rateset.neg]);

    fadeFrames = fadeTime * sr;

    // Main playhead
    phaseA = Phasor.ar(
        0,
        rateset,
        min(startFrame, endFrame),
        max(startFrame, endFrame),
        isReverse.if(endFrame, startFrame) // start at correct edge
    );

    // Define trigger point based on direction
    fadeStart = Select.kr(isReverse,
        [endFrame - fadeFrames, startFrame + fadeFrames]
    );

    jumpTrig = Trig1.ar(
        (isReverse.if(phaseA <= fadeStart, phaseA >= fadeStart)),
        0.001
    );

    // Second head jumps only when needed
    phaseB = Phasor.ar(
        jumpTrig,
        rateset,
        min(startFrame, endFrame),
        max(startFrame, endFrame),
        isReverse.if(endFrame, startFrame)
    );

    // Read buffer
    sigA = BufRd.ar(2, buf, phaseA);
    sigB = BufRd.ar(2, buf, phaseB);

    // Crossfade position (0–1)
    fadePos = Select.ar(isReverse,
        [
            (phaseA - (endFrame - fadeFrames)) / fadeFrames,   // forward
            ((startFrame + fadeFrames) - phaseA) / fadeFrames // reverse
        ]
    ).clip(0, 1).poll;

    xfade = XFade2.ar(sigA, sigB, (fadePos * 2) - 1);

    env = EnvGen.ar(Env.asr(attack, 1, release), gate, doneAction:2);
    Out.ar(0, xfade * amp * env);
}).add;
)


a=Buffer.read(s,"/home/zns/Documents/supercollisions/HGAT_120_alt_drum_loop_granular_key_bpm120_beats16_.flac");
c=Buffer.read(s,"/home/zns/Documents/supercollisions/ff_ma_130_synth_loop_distorted_Cmin_key_bpm200_130_beats32_.flac");
e=Buffer.read(s,"/home/zns/Documents/supercollisions/SO_DRR_104_choir_Epic_Cm_key_bpm200_104_beats16_.flac");
b=Synth(\xfadeLooper,[\buf,a,\loopStart,0,\loopEnd,0.5,\fadeTime,1.0,\rate,175/120]);
d=Synth(\xfadeLooper,[\buf,c,\loopStart,0,\loopEnd,0.5,\fadeTime,1.0,\rate,175/100]);
f=Synth(\xfadeLooper,[\buf,e,\loopStart,0,\loopEnd,0.5,\fadeTime,1.0,\rate,175/200]);

(
b.set(\gate,0);
d.set(\gate,0);
f.set(\gate,0);
b=Synth(\xfadeLooper,[\buf,a,\loopStart,0.0,\loopEnd,0.5,\fadeTime,0.01,\rate,175/120]);
// d=Synth(\xfadeLooper,[\buf,c,\loopStart,0,\loopEnd,1.0,\fadeTime,1.0,\rate,175/200]);
// f=Synth(\xfadeLooper,[\buf,e,\loopStart,0,\loopEnd,1.0,\fadeTime,1.0,\rate,175/200]);
)

