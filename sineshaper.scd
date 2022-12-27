(

b=Buffer.alloc(s,512,1);
b.cheby([1, 0.5, 1, 0.125]);
b.sine2([2],[0.5],false);b.plot;

c=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/pad_bpm120_beats64.wav");
)

// https://www.ableton.com/en/manual/live-audio-effect-reference/#24-37-saturator
(
{
	var snd=PlayBuf.ar(2,c,loop:1);
	snd=LeakDC.ar(snd);
	snd = SelectX.ar(0.2,[snd,Shaper.ar(b,snd)]);
}.play;
)