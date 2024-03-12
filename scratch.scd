b=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/drums1_8beats_bpm90.wav");
b=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/upright_16beats_bpm90.wav");

(
SynthDef("samplePlayer1scratchy", {
	arg bufnum=0, amp=1; // introduce a new argument called "amp"
    var snd;
	var rate = 1;
	var lfo;
	var trigger;
	var lfo_hz = MouseY.kr(1,6);
	amp=Lag.kr(amp,1); // Lag is a UGen that makes things change slowly

	trigger = MouseX.kr()>0.5;

	lfo = SinOsc.kr(lfo_hz);

	rate = rate * Select.kr(trigger,[1,lfo]);
    snd=PlayBuf.ar(
		numChannels:2,
		bufnum:b,
		loop:1,
		rate:rate // control rate with mouse
	);

	Out.ar(0,snd*amp);
}).play;
)
// put mouse all the way to the right, all the way left, and move it around fast!


~bufferPiano.play;
(
{
	var lfo_hz = 10;
	var timescale = 0.1;
	var ev = EnvGen.ar(Env.new([1,0,-1,0,1],[0.3/lfo_hz,0.2/lfo_hz,0.2/lfo_hz,0.3/lfo_hz],curve:\lin),Impulse.kr(lfo_hz/timescale),timeScale:timescale);
	[ev]
}.plot(0.1);
)