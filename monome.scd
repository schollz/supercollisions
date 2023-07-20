(
Server.default = Server.local;

~m = MonomeGrid.new(); // if we don't want to change rotation, we can leave the argument out

s.waitForBoot({

	var draw, timer, cols = 16, rows = 8;
	var syn;
	var press1=1.neg;
	var press2=1.neg;

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
		var pos01 = (x + (y/8))/16.0;
		pos01.postln;
		[x,y].postln;
		~press[pos]=z;
		if (z>0,{
			~step[pos] = z*15;
			draw.value;
			if (press1<0,{
				press1 = pos;
				syn.set(\pos,pos01,\do_trig,1);
			},{
				press2 = pos;
				syn.set(\retrig,pos01*32);
				if (pos>64,{
					syn.set(\do_ramp,1);
				});
			});
		},{
			if (press2>1.neg,{
				press2=1.neg;
				syn.set(\retrig,0);
				syn.set(\do_ramp,0);
			},{
				press1=1.neg;
				syn.set(\do_trig,0);
			});
		});
		[press1,press2].postln;
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

	/*	timer = Routine({
	var interval = 0.125;
	loop {
	draw.value;
	interval.yield;
	}
	});

	timer.play();
	*/



	SynthDef("0",{
		arg out,buf,start=0,dur=0.25,bpm=160,bpm_source=150,do_retrig=0,do_trig=0,do_ramp=0,pos=0,retrig=0;
		var snd,snd1,snd2,rate, phase1, phase2,trig;
		var retrig_rate =retrig*bpm/60/2;
		var quantize = Impulse.kr(bpm/60*2);
		rate=BufRateScale.ir(buf)*bpm/bpm_source;
		trig=ToggleFF.kr(((retrig_rate<1)*(quantize*do_trig))+((retrig_rate>0)*Impulse.kr(retrig_rate)));
		phase1=Phasor.ar(trig:trig,rate:rate,end:BufFrames.ir(buf),resetPos:pos*BufFrames.ir(buf));
		snd1=BufRd.ar(2,buf,phase1,interpolation:4);
		phase2=Phasor.ar(trig:1-trig,rate:rate,end:BufFrames.ir(buf),resetPos:pos*BufFrames.ir(buf));
		snd2=BufRd.ar(2,buf,phase2,interpolation:4);
		snd=SelectX.ar(Lag.kr(trig,0.05),[snd2,snd1]);
		snd=snd*SelectX.kr(Lag.kr(do_ramp),[1,EnvGen.ar(Env.new([0,36.neg,0],[0.05,(LFNoise0.kr(1).range(5,32).round/retrig_rate)]),do_ramp).dbamp]);
		SendReply.kr(Impulse.kr(10),"/pos",Select.kr(trig,[phase2,phase1])/BufFrames.ir(buf));
		// snd = Fverb.ar(snd[0],snd[1]);
		Out.ar(out,snd * 24.neg.dbamp);
	}).send(s);











	~oscPos = OSCFunc({ |msg|
		var pos=(msg[3]*cols)+1;
		var k1=pos.floor;
		var k2=(k1+1).wrap(1,17);
		var percent2=pos-k1;
		var percent1=1-percent2;
		var led1=(percent1*10).round;
		var led2=(percent2*10).round;
		for(0,~lastRow, {arg y;
			if (~step[y*16+k1-1]<1,{
				~step[y*16+k1-1]=led1;
			});
			~step[y*16+k2-1]=led2;
		});
		draw.value;
	}, '/pos');


	Routine {
		s.sync;

		b=Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/HGAT_120_full_drum_loop_granular_key_bpm120_beats16_.flac");
		//b=Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/vocals_bpm100.flac");
		s.sync;

		syn=Synth("0",[
			out:0,
			buf:b,
			bpm:150,
			bpm_source:120,
		]);
	}.play;

});

)