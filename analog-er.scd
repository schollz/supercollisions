(
b = Buffer.alloc(s,s.sampleRate*4,2);
c=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/beats16_bpm150_Ultimate_Jack_Loops_014__BPM_150_.wav");
)


(
var riddim = { |beatTime=0.125, divEnvTime=0.99, syncTime1=0.333, syncTime2=0.2, amp1=0.1, amp2=0.5, amp3=0.9|
    var takitak = Impulse.ar(beatTime.reciprocal);
    var divFeedback = LocalIn.ar(1);
    var tokitokGate = Env.step(levels: [1, 0], times: [1, 0]);
    var tokitok = EnvGen.ar(tokitokGate, takitak * (1 - divFeedback) + Impulse.ar(0), timeScale: divEnvTime, doneAction: Done.none);
    var prong = Phasor.ar(tokitok, syncTime2.reciprocal / SampleRate.ir);
    var pring = Phasor.ar(tokitok, syncTime1.reciprocal / SampleRate.ir);
    var dong = SetResetFF.ar(takitak, prong > 0.1).poll;
    var ding = SetResetFF.ar(takitak, pring > 0.1).poll;
    var dang = SetResetFF.ar(dong, ding).poll;
    var filt = { |thing, hp, lp, highres, lowres|
        var gend = EnvGen.ar(Env.perc(0.01*beatTime, 0.5*beatTime), thing, doneAction: Done.none);
        var band = RLPF.ar(RHPF.ar(gend, hp, highres), lp, lowres);
        band
    };
    var dongF = filt.value(dong, 100, 800, 0.3, 0.4);
    var dingF = filt.value(ding, 600, 1400, 0.5, 0.5);
    var dangF = filt.value(dang, 1500, 4000, 0.4, 0.5);
    LocalOut.ar([tokitok]);
	LPF.ar(((amp1*dongF) + (amp2*dingF) + (amp3*dangF)).tanh,900);
};

{
	riddim.value(0.1, 2, SinOsc.kr(0.123).range(0.125,1), SinOsc.kr(0.223).range(0.125,1))
}.play;

)

