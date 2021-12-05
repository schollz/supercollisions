// hotroded version of "08091500Acid309 by_otophilia". With additional basssynth, euclidian patterns (needs the Bjorklund Object). With some randomisation for bass- and leadsynth.


// -------- The Beat---------

~dseq = [Bjorklund.new(2,12), Bjorklund.new(4,9)*4, Bjorklund.new(2,6)+1*(Bjorklund.new(7,16)*2), Bjorklund.new(4,9), Bjorklund.new(5,12)].flop;

~dseq = [Bjorklund.new(3,8), Bjorklund.new(3,16).rotate(3)*3.5, Bjorklund.new(4,16).rotate(2)*4, Bjorklund.new(15,16)*4, Bjorklund.new(7,12)].flop;

~dseq = [Bjorklund.new(3,8), Bjorklund.new(4,9).rotate(0)*3.5, Bjorklund.new(4,16).rotate(2)*4, Bjorklund.new(15,16)*4, Bjorklund.new(7,12)].flop;

~dseq = [Bjorklund.new(2,16).rotate(0), Bjorklund.new(9,16).rotate(4)*2+Bjorklund.new(11,16).rotate(4)*1, Bjorklund.new(5,16).rotate(3)*2.5, Bjorklund.new(4,8).rotate(2)*3.5+1,Bjorklund.new(5,16).rotate(2)].flop;

~dseq = [Bjorklund.new(5,16).rotate(0)*3, Bjorklund.new(5,8).rotate(4)*2+Bjorklund.new(0,16).rotate(1)*1, Bjorklund.new(3,16).rotate(2)*3, Bjorklund.new(4,8).rotate(2)*2.5+1,Bjorklund.new(5,16).rotate(2)].flop;

~dseq = [Bjorklund.new(4,16).rotate(0), Bjorklund.new(3,24).rotate(4)*4+Bjorklund.new(9,16).rotate(1)*1, Bjorklund.new(5,16).rotate(2)*3, Bjorklund.new(5,8).rotate(2)*2.5+1,Bjorklund.new(5,16).rotate(2)].flop;


// --------The Leadsynth-------

// Enter values for rhythm in "Bjorklund.new(k,n)". Glides and Accents are the second array, Notes the last Array. Glide and Notes are scrambled, the notelengths shiftet with "rotate.([some values].choose)".

~bseq = [Bjorklund.new(4,9).rotate([1,3,5,7].choose),[1,2,1,0, 1,1,0,2, 2,4,2,0, 1,0,1,4].scramble,[12,10,13,25,24,18,31,32, 33,23,18,6, 12,10,0,13].scramble + 31+12].flop;

~bseq = [Bjorklund.new(5,12).rotate([1,3,5,7].choose),[1,2,1,0, 1,1,0,2, 2,4,2,0, 1,0,1,4].scramble,[24,12,13,-2, 25,13,24,13, 18,6,-2,0, -12,-2,1,18].scramble + 31+12].flop;

~bseq = [Bjorklund.new(2,12).rotate([1,3,5,7].choose),[1,2,1,0, 1,1,0,2, 2,4,2,0, 1,0,1,4].scramble,[12,10,13,25, 24,36,37,34, 0,7,19,12, 13,10,37,34].scramble + 31+12].flop;

// More random
~bseq = [Bjorklund.new(rrand(3,9),[3,4,6,9,12,16].choose).rotate([1,3,5,7].choose),[1,2,1,0, 1,1,0,2, 2,4,2,0, 1,0,1,4].scramble,[27,12,13,10, 24,1,6,18, 12,13,10,0, -2,1,13,18].scramble + 31+24].flop;


// --------The Basssynth-----------

// F
// max steps 1-16
// steps 1-16
// intensities 1-16 (light = intensity)
// note probability 1-16

(
~chord=[0,4,7];
~chord=[0,3,7];
x=Array.fill(3,{ arg i;
	Synth(\pad,[\freq,(~chord[i]+60-7-3).midicps])
});
)
x.do({ arg item,i; item.set(\gate,0)});

// F/C Am/C Dm Db/F
~bseq = [Bjorklund.new(16,16).rotate([1,3,5,7].choose),[10,1,1,0,1,].scramble,[0,7,12,4,2,-1,11,12,19,24].scramble + 36+36-7].flop;
~bseq2
~bseq2 = [Bjorklund.new(15,16).rotate([0,2,4,6].choose),[1,1,1,10].scramble,[-7,-2,0,5,7,10,12,22,24].scramble + 36 ].flop;
~bseq2 = [Bjorklund.new(12,16).rotate([0,2,4,6].choose),[4,1,1,8,3,3,1,2].scramble,[-7,-7,-7,-7,-2,-2,-2,-2,0,7,10,12,22,24].scramble + 36-3 ].flop;
~bseq2 = [Bjorklund.new(16,16).rotate([0,2,4,6].choose),[4,1,1,8,3,3,1,2].scramble,[-7,-7,-7,-7,-2,-2,-2,-2,0,7,10,12,22,24].scramble + 36+2 ].flop;
~bseq2 = [Bjorklund.new(16,16).rotate([0,2,4,6].choose),[14,11,11,8,3,3,1,2].scramble,[-7,-7,-7,-7,-2,-2,-2,-2,0,7,10,12,22,24].scramble + 36-5 ].flop;


~dseq = [Bjorklund.new(4,12).rotate(0), Bjorklund.new(4,12).rotate(4)*3, Bjorklund.new(6,15).rotate(2)*3, Bjorklund.new(15,16)*4, Bjorklund.new(8,12)].flop;



~bseq = [Bjorklund.new(12,16).rotate([1,3,5,7].choose),[8,2,2,1].scramble,[12,10,13,25, 24,36,37,34, 0,7,19,12, 13,10,37,34].scramble + 36].flop;
~bseq2 = [Bjorklund.new(10,16).rotate([0,2,4,6].choose),[4,1,1,8,3,3,1,2].scramble,[-7,-7,-7,-7,-2,-2,-2,-2,0,7,10,12,22,24].scramble + 36 ].flop;


~bseq2 = [Bjorklund.new(10,16).rotate([0,2,4,6].choose),[4,1,1,8,3,3,1,2].scramble,[-7,-7,-7,-7,-2,-2,-2,-2,0,7,10,12,22,24].scramble + 36 + [-3,0,2].scramble].flop;


~bseq2 = [Bjorklund.new(12,16).rotate([0,2,4,6].choose),[8,8,1,8,8,1,2,2].scramble,[-7,-2,0,7,10,12,22,24].scramble + 36].flop;
// Amin
~bseq2 = [Bjorklund.new(12,16).rotate([2,2,4,6].choose),[4,1,1,8].scramble,[-7,-2,0,7,10,12,22,24].scramble + 36+4].flop;

// Dmin
~bseq2 = [Bjorklund.new(12,16).rotate([2,2,4,6].choose),[4,1,1,8].scramble,[-7,-2,0,7,10,12,22,24].scramble + 36-3].flop;
// Gmin
~bseq2 = [Bjorklund.new(12,16).rotate([2,2,4,6].choose),[4,1,1,8].scramble,[-7,-2,0,7,10,12,22,24].scramble + 36+2].flop;



~bseq2 = [Bjorklund.new(9,12).rotate([0,2,4,6].choose),[4,1,1].scramble,[0,0,0,0,7,12,22,24,-7,24,24,24,24].scramble + 31].flop;
[-7,-2,0,7,10,12,22,24]
[F ,Bb,C,G,Bb, C,Bb,C]

[-7,-2,0,7,10,12,22,24]
[0,12,10,12, 24,10,7,12, -2,7,-7,0, 10,-2,22,24]

~dseq = [Bjorklund.new(3,16).rotate(0), Bjorklund.new(4,16).rotate(4)*4, Bjorklund.new(3,16).rotate(2)*5, Bjorklund.new(3,16)*6, Bjorklund.new(8,12)].flop;


~bseq2 = [Bjorklund.new(2,6).rotate([0,2,4,6].choose),[1,2,1,0, 1,1,0,2, 2,4,2,0, 1,0,1,4].scramble,[0,12,10,12, 24,10,7,12, -2,7,-7,0, 10,-2,22,24].scramble + 31].flop;

// More random
~bseq2 = [Bjorklund.new(rrand(1,3),[3,6,8,9,12].choose).rotate([0,2,4,6].choose),[1,2,1,0, 1,1,0,2, 2,4,2,0, 1,0,1,4].scramble,[0,12,10,12, 24,10,7,12, -2,7,-7,0, 10,-2,22,24].scramble + 36].flop;

[-7,-2,0,7,10,12,22,24]


// Run first the Routine, then change patterns ~dseq, ~bseq and ~bseq2 in the upper part

(
Routine.run {var c; c = Condition.new; s.freeAll; TempoClock.all.do{|x|x.clear}; s.bootSync(c);

	( // **** SynthDefs ****

		SynthDef(\pad, {|freq, gate=1|
			var adsr = EnvGen.ar(Env.adsr(1e-8,1e-6,0.75,0.125), gate, doneAction:2);
			var nvoices1 = 4, nvoices2 = 3;
			var detune1 = 12, detune2 = 8;
			var env, snd, osc1, osc2;

			osc1 = {
				var m = 2**(detune1/1200).rand2;
				SawDPW.ar(m * freq/2)
				// DelayC.ar(, 0.02, freq.reciprocal.rand * lfo);
			}.dup(nvoices1);

			osc2 = {
				var m = 2**(detune2/1200).rand2;
				LFSaw.ar(m * freq)
			}.dup(nvoices2);

			snd = LPF.ar(osc1, 1600)+osc2;
			snd=Splay.ar(snd);
			snd=SelectX.ar(0,[snd,snd*LFPar.ar(MouseX.kr(0,16))]);
			env=EnvGen.ar(Env.new([0.01,1,1],[0.2,10],curve:\exp));
			snd=snd*env;
			Out.ar(0, Splay.ar(snd*adsr));
		}).add;
		SynthDef("kick", {
			arg outBus=0;
			var env0, env1, env1m, out;

			env0 =  EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.06, 0.26], [-4, -2, -4]), doneAction:2);
			env1 = EnvGen.ar(Env.new([110, 59, 29], [0.005, 0.29], [-4, -5]));
			env1m = env1.midicps;

			out = LFPulse.ar(env1m, 0, 0.5, 1, -0.5);
			out = out + WhiteNoise.ar(1);
			out = LPF.ar(out, env1m*1.5, env0);
			out = out + SinOsc.ar(env1m, 0.5, env0);

			out = out * 1.2;
			out = out.clip2(1);

			Out.ar(outBus, out.dup);
		}).add;

		SynthDef("snare", {
			arg outBus=0, amp=0.8;
			var env0, env1, env2, env1m, oscs, noise, out;

			env0 = EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.03, 0.10], [-4, -2, -4]));
			env1 = EnvGen.ar(Env.new([110, 60, 49], [0.005, 0.1], [-4, -5]));
			env1m = env1.midicps;
			env2 = EnvGen.ar(Env.new([1, 0.4, 0], [0.05, 0.13], [-2, -2]), doneAction:2);

			oscs = LFPulse.ar(env1m, 0, 0.5, 1, -0.5) + LFPulse.ar(env1m * 1.6, 0, 0.5, 0.5, -0.25);
			oscs = LPF.ar(oscs, env1m*1.2, env0);
			oscs = oscs + SinOsc.ar(env1m, 0.8, env0);

			noise = WhiteNoise.ar(0.2);
			noise = HPF.ar(noise, 200, 2);
			noise = BPF.ar(noise, 6900, 0.6, 3) + noise;
			noise = noise * env2;

			out = oscs + noise;
			out = out.clip2(1) * amp;

			Out.ar(outBus, out.dup);
		}).add;

		SynthDef("clap", {
			arg outBus=0, amp = 0.5;
			var env1, env2, out, noise1, noise2;

			env1 = EnvGen.ar(Env.new([0, 1, 0, 1, 0, 1, 0, 1, 0], [0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03], [0, -3, 0, -3, 0, -3, 0, -4]));
			env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.3], [0, -4]), doneAction:2);

			noise1 = WhiteNoise.ar(env1);
			noise1 = HPF.ar(noise1, 600);
			noise1 = BPF.ar(noise1, 2000, 3);

			noise2 = WhiteNoise.ar(env2);
			noise2 = HPF.ar(noise2, 1000);
			noise2 = BPF.ar(noise2, 1200, 0.7, 0.7);

			out = noise1 + noise2;
			out = out * 2;
			out = out.softclip * amp;

			Out.ar(outBus, out.dup);
		}).add;

		SynthDef("hat", {
			arg outBus=0, amp=0.3;
			var env1, env2, out, oscs1, noise, n, n2;

			n = 5;
			thisThread.randSeed = 4;

			env1 = EnvGen.ar(Env.new([0, 1.0, 0], [0.001, 0.2], [0, -12]));
			env2 = EnvGen.ar(Env.new([0, 1.0, 0.05, 0], [0.002, 0.05, 0.03], [0, -4, -4]), doneAction:2);

			oscs1 = Mix.fill(n, {|i|
				SinOsc.ar(
					( i.linlin(0, n-1, 42, 74) + rand2(4.0) ).midicps,
					SinOsc.ar( (i.linlin(0, n-1, 78, 80) + rand2(4.0) ).midicps, 0.0, 12),
					1/n
				)
			});

			oscs1 = BHiPass.ar(oscs1, 1000, 2, env1);
			n2 = 8;
			noise = WhiteNoise.ar;
			noise = Mix.fill(n2, {|i|
				var freq;
				freq = (i.linlin(0, n-1, 40, 50) + rand2(4.0) ).midicps.reciprocal;
				CombN.ar(noise, 0.04, freq, 0.1)
			}) * (1/n) + noise;
			noise = BPF.ar(noise, 6000, 0.9, 0.5, noise);
			noise = BLowShelf.ar(noise, 3000, 0.5, -6);
			noise = BHiPass.ar(noise, 1000, 1.5, env2);

			out = noise + oscs1;
			out = out.softclip;
			out = out * amp;

			Out.ar(outBus, out.dup);
		}).add;

		SynthDef("acid", {
			arg outBus=0, gate=1, pitch=50, amp=8;
			var env1, env2, out;
			pitch = Lag.kr(pitch, 0.12 * (1-Trig.kr(gate, 0.001)) * gate);
			env1 = EnvGen.ar(Env.new([0, 1.0, 0, 0], [0.001, 2.0, 0.04], [0, -4, -4], 2), gate, amp);
			env2 = EnvGen.ar(Env.adsr(0.001, 0.8, 0, 0.8, 70, -4), gate);
			out = LFSaw.ar(pitch.midicps, 2, -1);

			out = MoogLadder.ar(out, (pitch + env2/2).midicps+(LFNoise1.kr(0.2,1100,1500)),LFNoise1.kr(0.4,0.9).abs+0.3,3);
			out = LeakDC.ar((out * env1).tanh/2.7);

			Out.ar(outBus, out.dup);
		}).add;


		SynthDef("acid2", {
			arg outBus=0, gate=1, pitch=20, amp=3.5;
			var env1, env2, out;
			pitch = Lag.kr(pitch, 0.12 * (1-Trig.kr(gate, 0.001)) * gate);
			env1 = EnvGen.ar(Env.perc(0.001,0.7,4,-4), gate, amp);
			env2 = EnvGen.ar(Env.perc(0.001,0.3,600*MouseY.kr(0.5,4),-3), gate);
			out = LFPulse.ar(pitch.midicps, 0, 0.5);

			out = MoogLadder.ar(out, 100+pitch.midicps + env2,MouseX.kr(0.01,0.2,1));
			out = LeakDC.ar((out * env1).tanh);

			Out.ar(outBus, out.dup);
		}).add;


		SynthDef("fx", {
			arg outBus=0, gate=0;
			var out;

			out = In.ar(outBus, 2);
			out = FreeVerb2.ar( BPF.ar(out[0], 3500, 1.5), BPF.ar(out[1], 3500, 1.5), 1.0, 0.95, 0.15) * EnvGen.kr(Env.new([0.02, 0.3, 0.02], [0.4, 0.01], [3, -4], 1), 1-Trig.kr(gate, 0.01)) + out;
			out = LeakDC.ar(out/2);
			out = Limiter.ar(out, 1.0, 0.02);

			ReplaceOut.ar(outBus, Limiter.ar(out,0.9));
		}).add;
	);

	[[1, 2], [4, 5, 6]].flop;
	s.sync(c);

	( // **** Sequence ****

		~dseq = [Bjorklund.new(3,8), Bjorklund.new(3,16).rotate(4)*3.5, Bjorklund.new(4,16).rotate(2)*4, Bjorklund.new(15,16)*4, Bjorklund.new(7,12)].flop;

		~bseq = [Bjorklund.new(7,9).rotate([1,3,5,7].choose),[1,2,1,0, 1,1,0,2, 2,4,2,0, 1,0,1,4].scramble,[12,10,13,25,24,18,31,32, 33,23,18,6, 12,10,0,13].scramble + 31].flop;

		~bseq2 = [Bjorklund.new(1,6).rotate(2),[1,2,1,0, 1,1,0,2, 2,4,2,0, 1,0,1,4].scramble,[0,6,10,12, 13,18,10,12, -2,6,6,10, 13,12,22,24].scramble + 31].flop;

		~pnt = 0;
		~shf = 0.16;
		~bpm = 130;

		~clock = TempoClock(~bpm/60);

		~clock.sched(0.0, {
			var delta, bass,bass2;
			delta = if(~pnt%2 == 0){1/4 * (1+~shf)}{1/4 * (1-~shf)};

			s.bind{
				if(~pnt == 0){
					~group = Group.new;
					~acid = Synth.head(~group, "acid", [\gate, 0]);
					~acid2 = Synth.head(~group, "acid2", [\gate, 0]);
					~fx = Synth.after(~group, "fx");
				};

				~dseq.wrapAt(~pnt).do{|x, i|
					switch(i,
						0, { if( x>0 ){ Synth.head(~group, "kick") } },
						1, { if( x>0 ){ Synth.head(~group, "snare", [\amp, (x/4).squared*0.7]) } },
						2, { if( x>0 ){ Synth.head(~group, "clap", [\amp, (x/4).squared*0.5]) } },
						3, { if( x>0 ){ Synth.head(~group, "hat", [\amp, (x/4).squared*0.32]) } },
						4, { ~fx.set(\gate, (x>0).binaryValue) }
					);
				};

				bass = ~bseq.wrapAt(~pnt);
				~acid.set(\pitch, bass[2]);
				if(bass[0]==1){ ~acid.set(\gate, 1) };

				bass2 = ~bseq2.wrapAt(~pnt);
				~acid2.set(\pitch, bass2[2]);
				if(bass2[0]==1){ ~acid2.set(\gate, 1) };
			};
			if(bass[1]>0){ ~clock.sched(delta * bass[1]/4 * 0.99, { s.bind{ ~acid.set(\gate, 0) } }) };

			if(bass2[1]>0){ ~clock.sched(delta * bass2[1]/4 * 0.99, { s.bind{ ~acid2.set(\gate, 0) } }) };

			~pnt = ~pnt+1;
			delta;
		});
	);

});


~dseq = [Bjorklund.new(5,16).rotate(2)*0.5, Bjorklund.new(2,16).rotate(4)*6, Bjorklund.new(4,16).rotate(2)*5, Bjorklund.new(14,16)*6, Bjorklund.new(4,12)].flop;
