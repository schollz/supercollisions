(
SynthDef("tinydrum",{
	arg t_trig=0,oL=1.0,nL=0.1,nA=0.01,nD=0.02,oA=0.01,oD=0.4,oF=60,click=0;
	var osc,noise,oscEnv,noiseEnv,snd;

	// sine
	osc=SinOsc.ar(
		Env([2.5*oF,1.225*oF,oF],[oA,oD],\exp).kr
	);
	// envelope
	oscEnv=Env.perc(oA,oD,oL).ar;

	// white noise
	noise=WhiteNoise.ar(0.1);
	 // a percussive click to give it some attack
	noiseEnv=EnvGen.ar(Env.linen(0.001, 0.01, 0.001,click));
	// rest of the envelope
	noiseEnv=noiseEnv+EnvGen.ar(Env.perc(nA,nD,nL).delay(0.01));

	// add together
	snd=(osc*oscEnv)+(noise*noiseEnv);

	// tiny distortion
	snd = (snd*5).tanh/5;

	snd = Pan2.ar(snd,0);

	DetectSilence.ar(snd,doneAction:2);

	Out.ar(0,snd);
}).add;
// euclidean rhythms
~er = { | o = 1, p = 16 |(o / p * (0..p - 1)).floor.differentiate.asInteger.min(1)[0] = if (o <= 0) { 0 } { 1 };};
)

(
{Env.perc(0.05, 0.2).delay(0.01).ar(2)}.plot(0.3)
)

// drum instruments
(
~kicksound={Synth("tinydrum",[\nL,0.01,\nA,0.1,\nD,0.4,\oL,1.2,\oA,0.01,\oD,0.6,\oF,40])};
~hhsound={Synth("tinydrum",[\nL,0.15,\nA,0.001,\nD,0.09,\oL,0.0025,\oA,0.001,\oD,0.1,\oF,1300,\click,0.2])};
~ohsound={Synth("tinydrum",[\nL,0.2,\nA,0.01,\nD,0.45,\oL,0.006,\oA,0.01,\oD,0.3,\oF,700,\click,0.3])};
~sdsound={Synth("tinydrum",[\nL,0.5,\nA,0.05,\nD,0.3,\oL,0.2,\oA,0.04,\oD,0.2,\oF,160,\click,1.5])};
)


s.record;

s.stopRecording;

// euclidean rhythms
~kick=~er.(0);
~oh=~er.(0);
~hh=~er.(0);
~sd=~er.(0);
~kick=~er.(2);
~kick=~er.(2).rotate(2);
~kick=~er.(3).rotate(2)+~er.(1);
~hh=~er.(0);
~hh=~er.(4).rotate(2);
~hh=~er.(4).rotate(2)+~er.(7);
~hh=~er.(14).rotate(2);
~hh=~er.(16)-~er.(2);
~oh=~er.(0);
~oh=~er.(2);
~oh=~er.(5);
~sd=~er.(0);
~sd=~er.(2).rotate(6);
~sd=~er.(2).rotate(6)+~er.(1).rotate(5);
~sd=~er.(2)+~er.(rrand(5,6).postln).rotate(2);




(
x=~kicksound.();
y=~hhsound.();
z=~sdsound.();
t.stop;
t = Task({
    var bpm=120;
    var beats=16;
    inf.do({ arg i;
        ~rand56=rrand(5,6);
		if (~kick[i%beats]>0,{
            if (x.isPlaying,{
                x.free;
            });
            x=~kicksound.();
        });
		if (~hh[i%beats]>0,{
            if (y.isPlaying,{
                y.free;
            });
            y=~hhsound.();
        });
		if (~oh[i%beats]>0,{
            if (y.isPlaying,{
                y.free;
            });
            y=~ohsound.();
        });
        if (~sd[i%beats]>0,{
            if (z.isPlaying,{
                z.free;
            });
            z=~sdsound.();
        });
        (60/bpm/4).wait;
    });
}).play;
)





