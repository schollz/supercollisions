(
Server.default = Server.local;

~m = MonomeGrid.new(); // if we don't want to change rotation, we can leave the argument out

s.waitForBoot({

	var draw, timer, cols = 16, rows = 8;
	var syn;
	var press1=1.neg;
	var press2=1.neg;
	var syns=Array.newClear(2);

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
	~press_col = Array.fill(cols,{0});
	~press_last=0;

	// 'cols' + 'rows' return as 1-indexed,
	// but we need 0-indexed for most of our functions!
	~lastCol = cols-1;
	~lastRow = rows-1;

	~m.key({ arg x,y,z;
		var pos = x + (y * 16);
		// [x,y].postln;
		~press[pos]=z;
		if (z>0,{
			~step[pos] = z*15;
		});
		if (y<syns.size,{
			~press_last = y;
			~press_col[y] = ~press_col[y] + (z*2-1);
			if (z>0,{
				if (~press_col[y]==1,{
					syns[y].set(\pos,x/15,\t_jump,1,\move_stop,1);
				});
				if (~press_col[y]==2,{
					syns[y].set(\move,x.linlin(0,15,0,4));
				});
			},{
				syns[y].set(\move_stop,0);
			});
		},{
			syns[~press_last].set(\freqmul,y.linlin(2,8,10,0.01));
			syns[~press_last].set(\rate,x.linlin(0,15,2.neg,2));
		});

		draw.value;
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

	timer.play();






	~oscPos = OSCFunc({ |msg|
		var num=msg[3];
		var pos=msg[4];
		var mx=msg[5];
		var my=msg[6];
		~step[(pos*15).round+(num*cols)]=15;
		if (num==~press_last,{
			[mx,my].postln;
			~step[my*16+mx]=15;
		});
		draw.value;
	}, '/pos');


	Routine {


		SynthDef("fx",{
			var snd=In.ar(0,2);
			var rev = Fverb.ar(snd[0],snd[1],
				predelay:50,
				tail_density:LFNoise2.kr(1/3).range(50,90),
				decay:LFNoise2.kr(1/3).range(50,90)
			);
			snd = SelectX.ar(LFNoise2.kr(1/3).range(0.1,0.3).poll,[snd,rev]);
			//snd = AnalogTape.ar(snd,0.9,0.9,0.9,4);
			ReplaceOut.ar(0,snd);
		}).send(s);



		SynthDef("grain",{
			arg buf,freq=1,move=1,pos=0,t_jump=0,move_stop=0,db=0,num=0,freqmul=1,rate=1;
			var snd,phase;
			//freqmul = MouseY.kr(0.1,10);
			//rate = MouseX.kr(2.neg,2);
			freqmul = VarLag.kr(freqmul,(num*10)+1,warp:\sine);
			rate = VarLag.kr(rate,(num*10)+1,warp:\sine);
			phase = Phasor.ar(trig:t_jump,rate:(1-move_stop)*move*rate/BufFrames.ir(buf),resetPos:pos);
			freq = freq * freqmul;
			snd = GrainBuf.ar(
				numChannels: 2,
				trigger: Impulse.kr(freq)+t_jump,
				dur: LFNoise2.kr(1/3).range(0.25,2)/freq,
				sndbuf: buf,
				pos: phase,
				rate: rate.sign*[1,0.5,2],
				interp: 4,
				pan: (LFNoise2.kr(1!3)),
				maxGrains: 64,
				mul: [1,0.25,0.05]
			);
			snd = Mix.new(snd);
			SendReply.kr(Impulse.kr(freq),"/pos",[num,phase,rate.linlin(2.neg,2,0,15).round,freqmul.linlin(0.1,10,7,2).round]);
			Out.ar(0,snd * 12.neg.dbamp * db.dbamp);
		}).add;

		s.sync;
		s.record;

		b=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/vocals_bpm100.flac",channels:[0]);
		s.sync;
		// c=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/synth_dm_bpm130.flac",channels:[0]);
		c=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/pad_bpm124_dm.flac",channels:[0]);
		s.sync;
		//b=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/kalimba.wav",channels:[0]);

		s.sync;
		x = Synth.tail(s,"fx");
		s.sync;
		syns[0]=Synth.head(s,"grain",[\buf,b,\move,1,\num,0,\db,-3,\pos,0,\t_jump,1]);
		syns[1]=Synth.head(s,"grain",[\buf,c,\move,1,\num,1,\db,0]);
	}.play;

});

)

z.set(\pos,0.4,\t_jump,1);

12.linlin(0,15,-2,2)
0.linexp(0,15,0.01,10)

