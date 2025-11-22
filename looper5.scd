(
SynthDef(\xfadeLooper, {
    |buf=0, freq=0.5, loopStart=0.3, loopEnd=0.0, fadeTime=0.1,
     gate=1, amp=1, attack=0.01, release=1|

    var rate, sr, bufFrames, startFrame, endFrame, fadeFrames;
    var phaseA, phaseB, sigA, sigB, fadePos, xfade, env;
    var isReverse, jumpTrig, fadeStart, fadeEnd;

    rate = freq / BufRateScale.kr(buf); // pitch-corrected
    sr = BufSampleRate.kr(buf);
    bufFrames = BufFrames.kr(buf);

    // Convert loop points (fractions) into buffer frames
    startFrame = loopStart * bufFrames;
    endFrame   = loopEnd * bufFrames;

    // Detect reverse if loopStart > loopEnd
    isReverse = (loopStart > loopEnd);

    // Reverse playback if needed
    rate = Select.kr(isReverse, [rate, rate.neg]);

    fadeFrames = fadeTime * sr;

    // Main playhead
    phaseA = Phasor.ar(
        0,
        rate,
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
        rate,
        min(startFrame, endFrame),
        max(startFrame, endFrame),
        isReverse.if(endFrame, startFrame)
    );

    // Read buffer
    sigA = BufRd.ar(1, buf, phaseA);
    sigB = BufRd.ar(1, buf, phaseB);

    // Crossfade position (0–1)
    fadePos = Select.kr(isReverse,
        [
            (phaseA - (endFrame - fadeFrames)) / fadeFrames,   // forward
            ((startFrame + fadeFrames) - phaseA) / fadeFrames // reverse
        ]
    ).clip(0, 1);

    xfade = XFade2.ar(sigA, sigB, (fadePos * 2) - 1);

    env = EnvGen.ar(Env.asr(attack, 1, release), gate, doneAction:2);
    Out.ar(0, xfade * amp * env);
}).play;
)
