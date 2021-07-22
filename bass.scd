(
play({
    Klank.ar(`[
        Array.rand(12, 800.0, 4000.0),         // frequencies
        nil,                             // amplitudes (default to 1.0)
        Array.rand(12, 0.1, 2)                // ring times
        ], Decay.ar(Impulse.ar(4), 0.03, ClipNoise.ar(0.01)))
})
)

(
x={
	arg note=35,t_trig=1;
	var snd;
	snd=Pulse.ar(note.midicps,width:SinOsc.kr(1/3).range(0.2,0.4));
	snd=snd+LPF.ar(WhiteNoise.ar(SinOsc.kr(1/rrand(3,4)).range(1,rrand(3,4))),2*note.midicps);
	snd = Pan2.ar(snd,LFTri.kr(1/6.12).range(-0.2,0.2));
	snd = HPF.ar(snd,60);
	snd = LPF.ar(snd,2*note.midicps);
	// snd = (snd*LFTri.kr(1/11).range(1,10)).tanh; // distortion
	//snd = Normalizer.ar(snd,1.0); // normalizer
	//snd = snd * EnvGen.ar(Env.perc(0.1,2),t_trig,doneAction:2);
	snd = snd*(60/note.midicps);
	Out.ar(0,snd.tanh);
}.play
)
x.set(\note,30,\t_trig,1)

20.midicps