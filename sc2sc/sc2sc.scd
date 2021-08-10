// https://gist.githubusercontent.com/catfact/37a95b4bdbed8792f0a22cd472bacd91/raw/a9e5286204e4e68afc0eb1a23029ba672fc41240/chunked_audio_capture.scd
// write audio input to multiple, equally sized, contiguous .wav chunks
(
	Routine {

		~packetFrames = 45056;
		~bufFrames = ~packetFrames * 2;
		b = Buffer.alloc(s, ~bufFrames, 2);

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
				b.write(path, "wav", ~bufFrames/2, startFrame);
			});
		},'/tr', s.addr);


		//// synths and busses
		// NB: my first attempt did this in one synthdef,
		// but it seems like multiple SendTrigs in one synth don't work.
		// so isntead the phase is split out to a bus, and two different trigger synths are assigned to it.
		~phase_b = Bus.audio(s);

		s.sync;
		~phase_s = {
			Out.ar(~phase_b.index, Phasor.ar(0, BufRateScale.kr(b.bufnum), BufFrames.kr(b.bufnum)));
			nil
		}.play(s);
		s.sync;

		~cap_s = {
			BufWr.ar(SoundIn.ar([0, 1]), b, In.ar(~phase_b));
			nil
		}.play(~phase_s, addAction:\addAfter);

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

	}.play;
)


// test: load captures, concatenate and play back
(
n = 5;
b = Buffer.alloc(s, ~packetFrames * n, 2);

~paths = Array.fill(n, { arg i;
	"%/%.wav".format(~basePath, i);
});

~paths.do({ arg p, i;
	postf("reading: %\n", p);
	b.read(p, bufStartFrame: ~packetFrames * i);
});

b.plot;
{ PlayBuf.ar(2, b, doneAction:2) }.play(s);
)



// playback
(

s.waitForBoot {
    ~packetSamples=45056;

    SynthDef.new(\continuous, {
        arg buf, out=0, amp=1;
        Out.ar(out, PlayBuf.ar(2, buf,loop:1.0) * amp);
    }).send(s);

    c=Buffer.alloc(s,~packetSamples*2,2);
    s.sync;

    Routine {
        s.sync;
        c.read(thisProcess.nowExecutingPath.dirname++"/0.wav",action:{
            x=Synth.new(\continuous, [\buf,c.bufnum]);
        });
        (~packetSamples/s.sampleRate/2).wait;
        8.do { arg i;
            c.read(thisProcess.nowExecutingPath.dirname++"/"++((i+1))++".wav",bufStartFrame:((i+1)%2)*~packetSamples);
            (~packetSamples/s.sampleRate).wait;
        };
        0.5.wait;
        x.free;
    }.play;
}
)



(
SynthDef("upload",{
    SendTrig.kr(Impulse.kr(1.0),0,1);
}).add;

// register to receive this message
~o1 = OSCFunc({ arg msg, time;
    [time, msg].postln;
    // send message to upload
    NetAddr("127.0.0.1",8765).sendMsg("/up","C:\\Users\\zacks\\Downloads\\up.wav");
},'/tr', s.addr);
~o2 = OSCFunc({ arg msg, time;
    [time, msg].postln;
    // message is received to load new file
},'/down');
)


Synth("upload");



























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