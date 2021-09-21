
c=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/sax_dmin_75bpm.wav");
d=Buffer.alloc(s,c.numFrames,c.numChannels);

c.plot;
c.play;
c.numFrames;

// generate zero indexes
(
Routine{
	~zeros=Array.new();
	c.loadToFloatArray(action: { arg array;
		var lastl=0;
		var lastr=0;
		var zcl=0;
		var zcr=0;
		c.numFrames.postln;
		array.size.postln;
		array.do({arg val, i;
			if ((i%2==0)&&(zcl>0)&&(zcr>0),{
				~zeros=~zeros.add((i/2-1)/(array.size/2));
			});
			if (i%2==0,{
				if ((lastl<0)&&(val>0),{
					zcl=1;
				},{
					zcl=0;
				});
				lastl=val;
			},{
				if ((lastr<0)&&(val>0),{
					zcr=1;
				},{
					zcr=0;
				});
				lastr=val;
			});
		});
		"done".postln;
	});
}.play;
)


~zeros.size;

(0.000002981298*c.numFrames)

// find zero index
(
~findZero={
	arg pos;
	var bestDiff=100;
	var bestPos=pos;
	~zeros.do({ arg val, i;
		if ((pos-val).abs<bestDiff,{
			bestDiff=(pos-val).abs;
			bestPos=val;
		});
	});
	bestPos
}
)
~findZero.(0.1).postln;
~findZero.(0.11).postln;

s.sampleRate/((~zeros[502]-~zeros[500])*c.numFrames)


)
(
SynthDef("play",{
	arg pos1=0.3,pos2=0.33;
	var snd,pos;
	pos=Phasor.ar(1,start:pos1*c.numFrames,end:pos2*c.numFrames,rate:0.25);
	snd=BufRd.ar(2,c,pos,0,4);
	Out.ar(0,snd);
}).add;
x=Synth("play",[\pos1,~findZero.(0.1),\pos2,~findZero.(0.15)]);
)
x.set(\pos1,~zeros[599]);
x.set(\pos2,~zeros[620]);
x.set(\pos1,~findZero.(0.3));
x.set(\pos2,~findZero.(0.31));
x.set(\pos1,0.30);
x.set(\pos2,0.31);

y=Synth("play",[\pos1,~findZero.(0.1),\pos2,~findZero.(0.12)]);
y.set(\pos1,~findZero.(0.6));
y.set(\pos2,~findZero.(0.62));

