(
Server.default = Server.local;

~m = MonomeGrid.new(); // if we don't want to change rotation, we can leave the argument out

s.waitForBoot({
	var draw, timer, cols = 16, rows = 8;
	var syn;
	MonomeGrid.setAddCallback({
		arg serial, port, prefix;
		("grid was added: " ++ serial ++ " " ++ port ++ " " ++ prefix).postln;
		if( serial == MonomeGrid.getConnectedDevices[0], {
			cols = ~m.cols;
			rows = ~m.rows;
		});
	});

	~m.connect(0); // if we don't want to connect to a second device, we can leave the argument out
	~step = Array.fill(cols * rows, {0});
	~press = Array.fill(cols * rows, {0});

	// 'cols' + 'rows' return as 1-indexed,
	// but we need 0-indexed for most of our functions!
	~lastCol = cols-1;
	~lastRow = rows-1;

	~m.key({ arg x,y,z;
		var pos = x + (y * 16);
		var idx = 15 - x;
		var notes = [48,57]++(60+(Scale.major.degrees++(Scale.major.degrees+12)));
		[x,y].postln;
		~press[pos]=z;
		if (z>0,{
			~step[pos] = z*15;
			~ins.noteOn(1,"/home/zns/Documents/supercollisions/samples/gentle_vibes",notes[idx],120,0);
		},{
			~ins.noteOff(1,notes[idx]);
		});
	});

	draw = {
		for(0,~lastCol, {arg x;
			for(0,~lastRow, {arg y;
				var pos=y*16+x;
				if (~step[pos]>0,{
					if (~press[pos]<1,{
						~step[pos]=~step[pos]-1;
					});
				});
				~m.led(x,y,~step[pos]);
			});
		})
	};

	timer = Routine({
		var interval = 0.125;
		loop {
			draw.value;
			interval.yield;
		}
	});


	Routine {
		~ins=InstrumentSample.new(Server.default);
		s.sync;
		timer.play();

		SynthDef(\bass, { arg freq = 440, amp = 0.5, gate = 1;
			var snd, env, oscfreq, output;
			var lfo;
			oscfreq = {freq * LFNoise2.kr(Rand(0.0001,0.5)).range(0.98, 1.02)}!10;
			lfo = { SinOsc.kr({ 1/Rand(2,52) }!10) };
			env = Env.adsr(0.2, 1, 0.9,0.1).kr(doneAction:2, gate: gate);
			output = LFSaw.ar(oscfreq, mul: lfo.value.range(0,1));
			output = Fold.ar(output,-0.5,0.5);
			output = RLPF.ar(output, (env*freq*0.7) + (freq * lfo.value.range(0.1,2)), lfo.value.range(0.2,1));
			output = Splay.ar(output, lfo.value.range(0,1));
			output = output * env * amp;
			Out.ar(0, output * 18.neg.dbamp);
		}).add;
		SynthDef("sine",{ arg freq=440, amp = 0.5, gate = 1;
			var snd;
			snd = SinOscFB.ar(freq,LFNoise2.kr(1/3).range(0,0.5));
			snd = snd * EnvGen.ar(Env.adsr(8,1,0.5,4),gate,doneAction:2);
			DetectSilence.ar(snd,doneAction:2);
			Out.ar(0, snd * amp * 12.neg.dbamp);
		}).send(s);

		SynthDef("final",{
			var snd, freq, dur;
			snd = In.ar(0,2);
			freq = LFNoise2.kr(1/3).range(0.5,10);
			dur = LFNoise2.kr(1/3).range(0.5,4);

			snd = SelectX.ar(LFNoise2.kr(1/5).range(0.1,0.55),[snd,
				Fverb.ar(snd[0],snd[1],50,
					tail_density: LFNoise2.kr(1/3).range(50,90),
					decay: LFNoise2.kr(1/3).range(50,90),
				)
			]);

			snd = snd * EnvGen.ar(Env.adsr(3,1,1,1));
			snd = HPF.ar(snd,100);
			snd = LPF.ar(snd,12000);
			ReplaceOut.ar(0,snd * Lag.kr(\db.kr(0),30).dbamp);
		}).send(s);

		s.sync;

		Synth.tail(s,"final");
		~chords=[
			[0,4,7],
			[0,4,9],
			[7.neg,3.neg,0],
			[0,4,9],
		];
		~syns = Array.newClear(4);

		inf.do{
			arg it;
			it.postln;
			3.do({ arg x;
				if (~syns[x].notNil,{
					~syns[x].set(\gate,0);
				});
				~syns[x]=Synth.head(s,"sine",[\freq,(48+~chords[it.mod(~chords.size)][x]).midicps.postln,\amp,16.neg.dbamp]);
			});
			(4+(12.rand)).sleep;

		};

	}.play;

});

)

[48,57]++(60+(Scale.major.degrees++(Scale.major.degrees+12))))


