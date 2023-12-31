(
b = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/1.flac"); //
)
c = Buffer.alloc(s, 512);
(
x = {
    var sig, chain, centroid, hicent, locent, fraccent, fraccentl, heaviness, heaviness2, kick2trig, kick2;
    sig = PlayBuf.ar(1, b.bufnum, BufRateScale.kr(b.bufnum) * 0.5, /*startPos: 92898, */loop: 1);
    // kick2 to emphasise the main downbeats
    kick2trig = Impulse.kr(BufDur.kr(b.bufnum).reciprocal * 4);
    kick2 = SinOsc.ar(50 + EnvGen.ar(Env.perc(0.001, 0.01, 1000, -10), kick2trig));
    kick2 = EnvGen.ar(Env.perc, kick2trig) * kick2 * 0.3;
    chain = FFT(c.bufnum, sig);
    //centroid = FFTCentroid.kr(chain).log.max(0.000001);
    centroid = FFTPercentile.kr(chain, 0.9);//.log.max(0.000001);
    hicent =     Amplitude.kr(centroid, 0, 10);
    locent = 10000 - Amplitude.kr(10000 - centroid, 0, 10);
    fraccent = ((centroid - locent) / (hicent - locent)).min(1).max(0);
    fraccentl = Latch.kr(fraccent, Onsets.kr(chain));
    Out.kr(0, fraccentl);
    // fraccent.poll;
    //heaviness = MouseX.kr(0,1);
    //heaviness2 = MouseY.kr(0,1);
    heaviness  = LFPar.kr(0.016, 0, 0.5, 0.5);
    heaviness2 = LFPar.kr(0.016, 1, 0.5, 0.5);
    // we don't go really mental until we've got going
    # heaviness, heaviness2 = [heaviness, heaviness2] * Line.kr(0.1, 1, 100);
    kick2 + Squiz.ar(sig,
        (   fraccentl  * LFNoise2.kr(0.1).exprange(1, 100) * heaviness) +
        ((1-fraccentl) * LFNoise2.kr(0.1).exprange(1, 100) * heaviness2) +
        0.8,
        zcperchunk: LFNoise2.kr(0.1).range(1, 10), mul:0.5).dup
    //sig
}.play(s);
)