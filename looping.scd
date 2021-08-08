
//write into the buffer with a BufWr
(
SynthDef("recorder",{ arg rate=1,bufnum=0;
    var in;
    in=SoundIn.ar([0,1]);
    //in = SinOsc.ar(LFNoise1.kr(2, 300, 400), 0, 0.1); // test fadeout with this
    BufWr.ar(in, bufnum, Phasor.ar(0, BufRateScale.kr(bufnum) * rate, 0, BufFrames.kr(bufnum)),0.0);
    FreeSelf.kr(TDelay.kr(Trig.kr(1),BufDur.kr(bufnum)));
    Out.ar(0,in*0);
}).add;

SynthDef("player",{ arg rate=1,bufnum=0,fadeOut=0.0;
    var playDur = BufDur.kr(bufnum)-fadeOut;
    var trig1 = Impulse.kr(1/(playDur/rate));
    var aOn = ToggleFF.kr(trig1);
    var snd;
    // remove clips using fadeout/fadein (buffer must be total time + fade out)
    snd = VarLag.kr(aOn,fadeOut*0.9)*BufRd.ar(2,bufnum,Phasor.ar(aOn, BufRateScale.kr(bufnum) * rate, 0, BufFrames.kr(bufnum)));
    snd = snd+(VarLag.kr(1-aOn,fadeOut*0.9)*BufRd.ar(2, bufnum, Phasor.ar(1-aOn, BufRateScale.kr(bufnum) * rate, 0, BufFrames.kr(bufnum))));
    // simple way
   // snd=BufRd.ar(2,bufnum,Phasor.ar(aOn, BufRateScale.kr(bufnum) * rate, 0, BufFrames.kr(bufnum)));

	// effects
	snd=LPF.ar(snd,MouseX.kr(20,20000,1));
    Out.ar(0,snd);
}).add;
)


(
~loopSize=60/124*2; // seconds
~fadeOut=0.1; // seconds
)



// clear buffers
(
~bufs=Array.fill(6,{ arg i;
	Buffer.alloc(s,s.sampleRate*(((i+1)*~loopSize)+~fadeOut),2)
});
)
// play all
(
~syns=Array.fill(6,{arg i;
    Synth("player",[\bufnum,~bufs[i],\fadeOut,~fadeOut]);
});
)
// .. and record one at a time
r= {arg i; Synth("recorder",[\bufnum,~bufs[i]])};
r.(0); // record into 1-second loop
r.(2); // record into 3-second loop
r.(1); // record into 2-second loop
r.(3); // etc
r.(4);
r.(5);
r.(6);

(
t = Task({
		inf.do({ arg i;
		rrand(1,2).postln
		});

}).play;

)

s.record;