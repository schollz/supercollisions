
// https://gist.githubusercontent.com/catfact/37a95b4bdbed8792f0a22cd472bacd91/raw/a9e5286204e4e68afc0eb1a23029ba672fc41240/chunked_audio_capture.scd
// write audio input to multiple, equally sized, contiguous .wav chunks
(
	~audioIn = Bus.audio(s,2);
	~audioOut = Bus.audio(s,2);
	~packetFrames = 45056;
	~uploaderPort = 8765;

	Routine {

		~bufFrames = ~packetFrames * 2;
		~outBuffer = Buffer.alloc(s, ~bufFrames, 2);

		~basePath = "D:/chunks";
		~chunkId = 0;

		~fudgeCount = 3;
		~oscTrig = OSCFunc({ arg msg, time;
			var id, startFrame, path;
			msg.postln;
			id = msg[2];

			if (~fudgeCount > 0, {
				~fudgeCount = ~fudgeCount - 1;
				postln("skipping this trigger...");
			}, {

				startFrame = switch(id, 1, {~bufFrames/2}, 2, {0});
				path = "%/%.wav".format(~basePath, ~chunkId);
				~chunkId = ~chunkId + 1;
				postf("saving: % (start frame: %)\n", path, startFrame);
				~outBuffer.write(path, "wav", ~bufFrames/2, startFrame);

				// tell the uploaded to upload it
				NetAddr("127.0.0.1",~uploaderPort).sendMsg("/up",path);
			});
		},'/tr', s.addr);


		//// synths and busses
		// NB: my first attempt did this in one synthdef,
		// but it seems like multiple SendTrigs in one synth don't work.
		// so isntead the phase is split out to a bus, and two different trigger synths are assigned to it.
		~phase_b = Bus.audio(s);

		s.sync;
		~phase_s = {
			Out.ar(~phase_b.index, Phasor.ar(0, BufRateScale.kr(~outBuffer.bufnum), BufFrames.kr(~outBuffer.bufnum)));
			nil
		}.play(s);
		s.sync;

		~cap_s = {
			arg audioBus, phaseBus;
			BufWr.ar(In.ar(inAudio), b, In.ar(phaseBus));
			nil
		}.play([\audioBus,~audioOut,\phaseBus,~phase_s],, addAction:\addAfter);

		// NB: the timing of the triggers isn't very critical;
		// what is important is that they dont get skipped.
		// so i'm adding a "fudge" period in frames,
		// mostly to ensure that the threshold comparison stays low
		// for at least a full control cycle at the start of the buffer.
		~trig_1_s = {
			var fudgeFrames, thresh1, phase;
			phase =  In.ar(~phase_b.index);
			fudgeFrames = ControlDur.ir / SampleDur.ir + 2;
			thresh1 = fudgeFrames;
			SendTrig.kr(A2K.kr(phase > thresh1), 1);
		}.play(~phase_s, addAction:\addAfter);

		~trig_2_s = {
			var fudgeFrames, thresh2, phase;
			phase =  In.ar(~phase_b.index);
			fudgeFrames = ControlDur.ir / SampleDur.ir + 2;
			thresh2 = BufFrames.kr(b) / 2 + fudgeFrames;
			SendTrig.kr(A2K.kr(phase > thresh2), 2);
		}.play(~phase_s, addAction:\addAfter);



		// playback

		~bufferedInput=Buffer.alloc(s,~packetFrames*2,2);
		~bufferedInputIterator=0;

	    SynthDef.new(\continuous, {
	        arg buf, out=0, amp=1;
	        Out.ar(out, PlayBuf.ar(2, buf,loop:1.0) * amp);
	    }).send(s);

	    s.sync;

		~receiver=Synth.new(\continuous, [\buf,~bufferedInput.bufnum,\out,0]);

		~o2 = OSCFunc({ arg msg, time;
		    [time, msg].postln;
		    // message is received to load new file
			c.read(msg[1],bufStartFrame:~bufferedInputIterator*~packetFrames,action{
				~bufferedInputIterator=1-~bufferedInputIterator;
			});
		},'/down');

	}.play;
)


// define synths

(
SynthDef("sine",{
	arg freq=220,amp=1.0,out=0;
	Out.ar(out,SinOsc.ar([freq,freq+2])*amp)	
}).add;
)

// this synth will be sent out!
x=Synth("sine",[\out,~audioOut]);


































// this doens't really work...
(
Routine {
var p, l;
    p = Pipe.argv(["ping","sourceforge.net"], "r");    // list directory contents in long format
l = p.getLine;                    // get the first line
while({l.notNil}, {l.postln; l = p.getLine; });    // post until l = nil
p.close;                    // close the pipe to avoid that nasty buildup
    "done".postln;
}.play;
)

(
Routine {
var p, l;
	"uploading".postln;
    p = Pipe.argv(["Invoke-WebRequest","-InFile","C:\Users\zacks\Desktop\temp\hello.txt","-uri","https://duct.schollz.com/zz","-Method","Post"], "r");
    l = p.getLine;
    while({l.notNil}, {l.postln; l = p.getLine; });    // post until l = nil
    p.close;                    // close the pipe to avoid that nasty buildup
    "done".postln;
}.play;
Routine {
var p, l;
	"downloading".postln;
    1.wait;
    p = Pipe.argv(["Invoke-WebRequest","-uri","https://duct.schollz.com/zz","-Method","Get"], "r");    // list directory contents in long format
    l = p.getLine;                    // get the first line
    while({l.notNil}, {l.postln; l = p.getLine; });    // post until l = nil
    p.close;                    // close the pipe to avoid that nasty buildup
    "done".postln;
}.play;
)