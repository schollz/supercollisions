(
s.waitForBoot({
	2.do({arg i;
		var numChannels=i+1;
		SynthDef("looper"++numChannels,{
			// main arguments
			arg buf,db=0,start=0,size=0.05,pitch=2,direction=1,pan=0,gate=1;
			var snd,snd1,snd2,pos,pos1,pos2,index;

			var amp = Lag.kr(db.dbamp,1);
			var frames=BufFrames.ir(buf);
			var duration=BufDur.ir(buf);
			var xfadetime = 0.02;

			// calculate the final rate
			var rate=pitch.midiratio*BufRateScale.kr(buf);

			// set the start/end points
			var posStart = Clip.kr(LinLin.kr(MouseX.kr(0,1,0,0.05)+LFNoise2.kr(0.3,0.1),0,1,0,frames),1024,frames-10240);
			var posDuration = MouseY.kr(xfadetime,0.5,1,0.05)/duration*frames;
			var posEnd = Clip.kr(posStart + posDuration,posStart+1024,frames-1024);

			// LocalIn collects the a trigger whenever the playhead leaves the window
			var switch=ToggleFF.kr(LocalIn.kr(1));


			// playhead 1 has a play position and buffer reader
			pos1=Phasor.ar(trig:1-switch,rate:rate,end:frames,resetPos:((direction>0)*posStart)+((direction<1)*posEnd));
			snd1=BufRd.ar(numChannels,buf,pos1,1.0,4);

			// playhead 2 has a play position and buffer reader
			pos2=Phasor.ar(trig:switch,  rate:rate,end:frames,resetPos:((direction>0)*posStart)+((direction<1)*posEnd));
			snd2=BufRd.ar(numChannels,buf,pos2,1.0,4);

			// current position changes according to the swtich
			pos=Select.ar(switch,[pos1,pos2]);

			// send out a trigger anytime the position is outside the window
			LocalOut.kr(
				Changed.kr(Stepper.kr(Impulse.kr(1/xfadetime),max:1000000000,
					step:(pos>posEnd)+(pos<posStart)
				))
			);

			// crossfade bewteen the two sounds over 50 milliseconds
			snd=SelectX.ar(Lag.kr(switch,xfadetime),[snd1,snd2]);

			// apply the start/stop envelope
			amp = amp * EnvGen.ar(Env.adsr(1,1,1,1),gate,doneAction:2);

			// do the panning
			if (numChannels>1,{
				snd=Balance2.ar(snd[0],snd[1],pan);
			},{
				snd=Pan2.ar(snd,pan);
			});

			// final output
			snd = snd * amp / 5;
			Out.ar(0,snd);
		}).add;
	});
	SynthDef("fx",{
		var snd=In.ar(0,2);
		var rev = Fverb.ar(snd[0],snd[1],
			predelay:50,
			tail_density:LFNoise2.kr(1/3).range(50,90),
			decay:LFNoise2.kr(1/3).range(50,90)
		);
		snd = SelectX.ar(LFNoise2.kr(1/3).range(0.1,0.3),[snd,rev]);
		//snd = AnalogTape.ar(snd,0.9,0.9,0.9,4);
		ReplaceOut.ar(0,snd);
	}).send(s);
	Routine {
		s.sync;
		Synth.tail(s,"fx");
		s.sync;
		Buffer.read(Server.default, thisProcess.nowExecutingPath.dirname++"/test1.wav", action: {arg buf;
			buf.postln;
			x=Synth.head(s,"looper2",[buf:buf]);
		});
		/*Buffer.read(Server.default, thisProcess.nowExecutingPath.dirname++"/AA_SC_AT_120_synth_chords_about_Amin_keyAmin_bpm120_beats16_.flac", action: {arg buf;
		buf.postln;
		x=Synth.head(s,"looper2",[buf:buf]);
		});
		Buffer.read(Server.default, thisProcess.nowExecutingPath.dirname++"/PMJO_Vocal_Sessions_New_Plan_120_Am_Vocal_Atmosphere_05_keyAmin_bpm120_beats32_.flac", action: {arg buf;
		buf.postln;
		y=Synth.head(s,"looper2",[buf:buf]);
		});*/
	}.play;
});
)

x.set(\pan,-0.5,\size,0.1,\start,0.6+rrand(-0.01,0.01));
y.set(\pan,0.5,\db,0,\end,0.606+rrand(-0.01,0.01),\start,0.6+rrand(-0.01,0.01));
