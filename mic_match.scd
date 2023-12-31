
(
s.waitForBoot({
	var powers = Array.newClear(3);
	var syns = Array.newClear(4);
	var comps = [-7,-13,-2,-5];
	var adds = [0,0,0,0];
	3.do({ arg i;
		powers[i] = Array.newClear(4);
	});
	OSCdef(\audio, {|msg, time, addr, recvPort|
		var id=msg[9].asInteger;
		4.do({arg i;
			powers[id][i]=msg[i+4];
		});
		if (id>0,{
			if (powers[0][0].notNil,{
				4.do({arg i;
					powers[2][i]=powers[0][i]-powers[1][i];
				});
				// powers[2].postln;
				4.do({ arg i;
					if (powers[2][i]>100,{
						adds[i] = adds[i]+0.1;
					});
					if (powers[2][i]<100.neg,{
						adds[i] = adds[i]-0.1;
					});
					syns[i].set(\db,comps[i]+adds[i]);
				});
				powers[2].postln;
				adds.postln;
			});
		});
	}, '/audio'); // def style
	SynthDef("microphone",{
		arg out=8;
		var snd;
		var snd_uncompensated;
		snd = SoundIn.ar(0);
		Out.ar(out,snd);
	}).send(s);

	SynthDef("sine",{
		arg out=0, freq=440, db=0;
		var snd;
		snd = SinOsc.ar(freq);
		Out.ar(out, snd * db.dbamp);
	}).send(s);
	SynthDef("audiofft",{
		arg out=0, id=0;
		var array, fft;
		var snd = In.ar(out);
		fft = FFT(LocalBuf(1024),snd);
		array = FFTSubbandPower.kr(fft, [110,330,530,3000,6000],scalemode:2);
		SendReply.kr(Impulse.kr(EnvGen.kr(Env.new([0,0,50],[10,0]))),"/audio",Lag.kr(array,1/50)++[id]);
	}).send(s);
	SynthDef("noise",{
		arg freq=440, db=0;
		var snd;
		snd = WhiteNoise.ar();
		Out.ar(0,snd * db.dbamp);
	}).send(s);
	s.sync;
	Synth("microphone",[\out:8]);
	Synth.tail(s,"audiofft",[\out:8,\id:1]);
	Synth("sine",[\freq:220,\db:comps[0],\out:4]);
	Synth("sine",[\freq:400,\db:comps[1],\out:4]);
	Synth("sine",[\freq:660,\db:comps[2],\out:4]);
	Synth("sine",[\freq:4040,\db:comps[3],\out:4]);
	Synth.tail(s,"audiofft",[\out:4,\id:0]);
	// uncompensated
	// Synth("sine",[\freq:220,\db:-8,\out:0]);
	// Synth("sine",[\freq:400,\db:-12,\out:0]);
	// Synth("sine",[\freq:660,\db:-2,\out:0]);
	// Synth("sine",[\freq:4040,\db:-8,\out:0]);
	// compensated
	syns[0]=Synth.head(s,"sine",[\freq:220,\db:comps[0]+adds[0],\out:0]);
	syns[1]=Synth.head(s,"sine",[\freq:400,\db:comps[1]+adds[1],\out:0]);
	syns[2]=Synth.head(s,"sine",[\freq:660,\db:comps[2]+adds[2],\out:0]);
	syns[3]=Synth.head(s,"sine",[\freq:4040,\db:comps[3]+adds[3],\out:0]);
	//
	{
		var w = Window("Audio", Rect(0, 0, 550, 300));
		var f = FreqScopeView(w, w.view.bounds,s);
		f.inBus = 4;
		f.freqMode = 1;
		f.dbRange = 20;
		f.active_(true); // turn it on the first time;
		w.onClose_({ f.kill }); // YOU MUST HAVE THIS
		w.front;
	}.();
	{
		var w = Window("Speaker (compensated audio)", Rect(550, 0, 550, 300));
		var f = FreqScopeView(w, w.view.bounds,s);
		f.inBus = 0;
		f.freqMode = 1;
		f.dbRange = 20;
		f.active_(true); // turn it on the first time;
		w.onClose_({ f.kill }); // YOU MUST HAVE THIS
		w.front;
	}.();
	{
		var w = Window("Microphone", Rect(1100, 0, 550, 300));
		var f = FreqScopeView(w, w.view.bounds,s);
		f.inBus = 8;
		f.freqMode = 1;
		f.dbRange = 20;
		f.active_(true); // turn it on the first time;
		w.onClose_({ f.kill }); // YOU MUST HAVE THIS
		w.front;
	}.();
})
)








