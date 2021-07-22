({
    var sig = 0;
    var freq= 0;

    freq = LFNoise0.kr(0.2).range(0.1,0.4);
    3.do {
        sig = SinOsc.ar(
            freq,
            LFNoise0.kr(1).range(40,60)  * sig
        );
    };
    3.do {
        sig = SinOsc.ar(
            freq*rand(0.5,1),
            LFNoise0.kr(1).range(40,60) * sig
        );
    };

    sig = HPF.ar( sig, 80 );
    sig=Pan2.ar( LeakDC.ar( sig ), SinOsc.kr(LFNoise0.kr(1).range(0.1,0.4)), 0.2 );
    sig=sig+((1-DetectSilence.ar(sig))*PinkNoise.ar(0.005));
    sig = sig + CombC.ar(sig,0.5,LFNoise0.kr(1).range(0.1,0.3),LFNoise0.kr(0.1).range(2,4),0.2);

    sig = sig*EnvGen.ar(Env.adsr(releaseTime:0.5),Pulse.kr(1));
    sig = FreeVerb2.ar(sig[0],sig[1],0.33,1.0,0.8);
    sig = MoogFF.ar(sig,4000,2.5);
}.play;
)

s.record;
s.stop;