(
var riddim = { |beatTime=0.125, divEnvTime=0.99, syncTime1=0.333, syncTime2=0.2, amp1=0.5, amp2=0.5, amp3=0.5|
    var takitak = Impulse.ar(beatTime.reciprocal);
    var divFeedback = LocalIn.ar(1);
    var tokitokGate = Env.step(levels: [1, 0], times: [1, 0]);
    var tokitok = EnvGen.ar(tokitokGate, takitak * (1 - divFeedback) + Impulse.ar(0), timeScale: divEnvTime, doneAction: Done.none);
    var prong = Phasor.ar(tokitok, syncTime2.reciprocal / SampleRate.ir);
    var pring = Phasor.ar(tokitok, syncTime1.reciprocal / SampleRate.ir);
    var dong = SetResetFF.ar(takitak, prong > 0.1);
    var ding = SetResetFF.ar(takitak, pring > 0.1);
    var dang = SetResetFF.ar(dong, ding);
    var deng = SetResetFF.ar(ding, dong);
    var filt = { |thing, hp, lp, highres, lowres|
        var gend = EnvGen.ar(Env.perc(0.01*beatTime, 0.5*beatTime), thing, doneAction: Done.none);
        var band = RLPF.ar(RHPF.ar(gend, hp, highres), lp, lowres);
        band
    };
	var dongF,dingF,dangF,dengF;
	dongF = SinOscFB.ar(EnvGen.kr(Env.new([50 * 6,50*6, 50], [0.0001,0.05], \exp),dong),0.4,0.5pi)*EnvGen.kr(Env.new([0.03,1, 0.8, 0], [0.0,0.3,0.15], -4),dong);
	dingF = (HPF.ar(BPeakEQ.ar(WhiteNoise.ar, 4000, 0.5, 3), 300)+ (SinOsc.ar(Env([400, 196, 160], [0.04, 0.2], \exp).ar))+LPF.ar(HPF.ar(WhiteNoise.ar, 300), 8000)) *EnvGen.ar(Env.perc(0.01,0.1),ding,0.2)*0.5;
	dangF = (SinOsc.ar(850)+PinkNoise.ar())*EnvGen.ar(Env.perc(0.01,0.2),dang,0.2);
	dengF = (SinOsc.ar(220)+PinkNoise.ar())*EnvGen.ar(Env.perc(0.01,0.2),deng,0.6);
    LocalOut.ar([tokitok]);
    ((amp1*dongF) + (amp2*dingF) + (amp3*dangF) + (amp3*dengF)).tanh;
};

{
    riddim.value(0.125, 2, MouseX.kr(0.125, 1, 1), MouseY.kr(0.125, 1, 1))
}.play

)

0.125.reciprocal