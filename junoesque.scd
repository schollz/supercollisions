(
SynthDef("lfo1",{
	arg out=0,freq=1;
	Out.kr(out,SinOsc.kr(freq));
}).add;
)


(
SynthDef("junoesque",{
	// basic parameters
	arg freq=220,attack=0.005,decay=0.1,sustain=0.5,release=1.0,amp=1.0,
	mod1=0.0,mod2=0.5,mod3=0.5,
	lfo1,
	// special parameters
	sub=0.9,pulse=0.9,saw=0.4,noise=0.2,gate=1,detuning=0.2;
	var env,  snd, tempGate;
	freq=freq;
	//tempGate=ToggleFF.kr(1-TDelay.kr(DC.kr(1),attack+decay));
	env=EnvGen.ar(
		Env.adsr(attack,decay,sustain,release),
		gate:gate,doneAction:Done.freeSelf
	);
	snd = Array.fill(2,{
		arg i;
		var freq2=freq+((freq-((freq.cpsmidi+detuning).midicps))*i);
		var snd2=SawDPW.ar(freq2,mul:saw/3);
		snd2=snd2+PulseDPW.ar(freq2/2,mul:sub/3);
		snd2=snd2+PulseDPW.ar(freq2,mul:pulse/3);
		snd2
	});
	snd = Mix.ar(snd);
	snd=MoogLadder.ar(snd,freq*3);

		snd= Mix.fill(6, {
			var maxdelaytime= rrand(0.01,0.03);
			var half= maxdelaytime*0.5;
			var quarter= maxdelaytime*0.25;
			DelayC.ar(snd, maxdelaytime, half+(quarter*LPF.ar(WhiteNoise.ar,SinOsc.kr(0.1,rrand(0,2*pi)).range(5,15))))/6
		});
	snd=HPF.ar(snd,60);

	snd = snd * amp.poll * env;
	snd = snd.tanh;
	DetectSilence.ar(snd,doneAction:2);
	Out.ar(0,Pan2.ar(snd));
}).add;
)

// define the lfos
(
~lfo1=Bus.control(s);
Synth("lfo1",[\out,~lfo1]);
)

// ~10% cpu on Dell
Pbind(\instrument, \junoesque, \amp,1,\freq, Pseq(([60,62,65,60,62,65,60,62,65,60,62,65,58,62,67,58,62,67,58,62,67,58,62,67]).midicps, inf), \dur, Pseq([0.2],inf)).play;

// now you can create multiple instances of them!
(
x = Synth("junoesque",[\freq,60.midicps]);
y = Synth("junoesque",[\freq,62.midicps]);
z = Synth("junoesque",[\freq,65.midicps]);
)

(
x.set(\freq,58.midicps);
y.set(\freq,62.midicps);
z.set(\freq,67.midicps);
)
(
x.set(\freq,60.midicps);
y.set(\freq,62.midicps);
z.set(\freq,65.midicps);
)


// midi controller
(
var notes, on, off;

MIDIClient.init;
MIDIIn.connectAll;

notes = Array.newClear(128);    // array has one slot per possible MIDI note

on = MIDIFunc.noteOn({ |veloc, num, chan, src|
    notes[num] = Synth("junoesque", [\freq, num.midicps,
        \amp, veloc * 0.00315]);
});

off = MIDIFunc.noteOff({ |veloc, num, chan, src|
    notes[num].set(\gate,0);
});

q = { on.free; off.free; };
)

// when done:
q.value;