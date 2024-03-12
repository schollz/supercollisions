
(
var f1=PathName.new("/home/zns/Music/spliceloop2/strings-orchestral-a/120/").files.scramble[0].asAbsolutePath;
~getOnsets={ arg fname;
	var p, l;
	var onsets = [];
	p = Pipe.new("aubioonset -t 0.1 -O specdiff"+f1, "r");            // list directory contents in long format
	l = p.getLine;                    // get the first line
	while({l.notNil}, {
		l.postln;
		onsets=onsets.add(l.asFloat);
		l = p.getLine;
	});    // post until l = nil
	p.close;  // close the pipe to avoid that nasty buildup
	onsets
};
~onsets=~getOnsets.(f1);
)


(
s.waitForBoot({
	var f1=PathName.new("/home/zns/Music/spliceloop2/strings-orchestral-a/110").files.scramble[0].asAbsolutePath;
	var f2=PathName.new("/home/zns/Music/spliceloop2/chords-synth-am/90/").files.scramble[0].asAbsolutePath;
	// var f2=PathName.new("/home/zns/Music/spliceloop2/drums-ambient/90/").files.scramble[0].asAbsolutePath;
	~getOnsets={ arg fname;
		var p, l;
		var onsets = [];
		p = Pipe.new("aubioonset -t 0.1 -O specdiff"+f1, "r");            // list directory contents in long format
		l = p.getLine;                    // get the first line
		while({l.notNil}, {
			l.postln;
			onsets=onsets.add(l.asFloat);
			l = p.getLine;
		});    // post until l = nil
		p.close;  // close the pipe to avoid that nasty buildup
		onsets
	};
	~f1places=~getOnsets.(f1);
	~f2places=~getOnsets.(f2);
	Routine{
		SynthDef("fx",{
			var snd, rev;
			snd=In.ar(0,2);
			snd = AnalogTape.ar(snd,0.9,0.9,0.6);
			rev = Fverb.ar(snd[0],snd[1],
				predelay:50,
				tail_density:LFNoise2.kr(1/3).range(50,90),
				decay:LFNoise2.kr(1/3).range(50,90)
			);
			snd = SelectX.ar(LFNoise2.kr(1/3).range(0.5,0.9),[snd,rev]);
			ReplaceOut.ar(0,snd);
		}).send(s);

		SynthDef("grain",{
			arg buf,pos=0,t_jump=1,db=0,rate=0.5,pan=0;
			var phase, snd;
			phase = Phasor.ar(
				trig:t_jump,
				rate:rate*BufRateScale.ir(buf)/BufFrames.ir(buf),
				start:0,
				end:1,
				resetPos:pos,
			);
			snd = GrainBuf.ar(
				numChannels: 1,
				trigger: Dust.kr(MouseX.kr(0.5,1))+Impulse.kr(MouseX.kr(3,8)),
				dur: MouseY.kr(0.5,2)/MouseX.kr(3,8),
				sndbuf: buf,
				pos: phase,
				rate: 1,
				interp: 4,
				maxGrains: 64,
				mul: 1,
			);
			snd = Pan2.ar(snd,pan);
			Out.ar(0,snd * 12.neg.dbamp * db.dbamp);
		}).send(s);

		s.sync;

		// MIDIIn.connectAll;
		// 3.wait;
		// c = MIDIFunc.cc({arg ...args; args.postln}, (1..127)); // match cc 1-10

		z=Synth.tail(s,"fx");
		s.sync;
		Buffer.readChannel(s,f1,channels:0,action:{
			arg buf;
			buf.postln;
			~f1places = ~f1places/buf.duration;
			x=Synth.head(s,"grain",[\buf,buf,\pan,-1]);
		});
		Buffer.readChannel(s,f1,channels:1,action:{
			arg buf;
			buf.postln;
			//~f1places = ~f1places/buf.duration;
			y=Synth.head(s,"grain",[\buf,buf,\pan,1]);
		});
		Buffer.readChannel(s,f2,channels:0,action:{
			arg buf;
			buf.postln;
			~f2places = ~f2places/buf.duration;
			z=Synth.head(s,"grain",[\buf,buf]);
		});
	}.play;

});
)


(
var place = ~f1places.choose.postln;
var rate = (2.rand*2-1)*(20.rand/10);
x.set(\pos,place,\t_jump,1,\rate,rate.postln,\db,-12);
y.set(\pos,place,\t_jump,1,\rate,rate,\db,-12);
)
z.set(\pos,~f2places.choose.postln,\t_jump,1,\rate,(2.rand*2-1)*(30.rand/10),\db,3);