a=Buffer.read(Server.default, thisProcess.nowExecutingPath.dirname++"/pulsar-23 postsolarpunk pack/Kick Comp and EQ/kick comp eq 31 [2022-07-04 181312].wav");
b=Buffer.read(Server.default, thisProcess.nowExecutingPath.dirname++"/pulsar-23 postsolarpunk pack/Snare 3/snare65 [2022-07-04 230524].wav");
c=Buffer.read(Server.default, thisProcess.nowExecutingPath.dirname++"/pulsar-23 postsolarpunk pack/Bass High Quantity/bass330 [2022-07-04 165455].wav");
d=Buffer.read(Server.default, thisProcess.nowExecutingPath.dirname++"/pulsar-23 postsolarpunk pack/Noise Patch/Slice 17 [2021-05-10 222151].wav");
c.play;

(
var riddim = { |beatTime=0.125, divEnvTime=0.99, syncTime1=0.333, syncTime2=0.2, amp1=0.5, amp2=0.5, amp3=0.5,amp4=0.1|
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
	dongF = PlayBuf.ar(2,a,1.0,dong);
	dingF = PlayBuf.ar(2,b,1.0,ding);
	dangF = PlayBuf.ar(2,c,1.0,dang);
	dengF = PlayBuf.ar(2,d,1.0,deng);
	(((amp1*dongF) + (amp2*dingF) + (amp3*dangF) + (amp4*dengF))*8).tanh;
};

{
    riddim.value(0.125, 8, MouseX.kr(0.125/4, 1, 1), MouseY.kr(0.125/4, 1, 1))
}.play

)

0.125.reciprocal