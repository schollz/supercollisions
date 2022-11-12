
(
c=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/beats16_bpm150_Ultimate_Jack_Loops_014__BPM_150_.wav");
)

c.play

(
SynthDef("play",{
	arg out=0,buf,startFrame,endFrame=0,duration=0,rate=1;
	var snd;
	endFrame=Select.kr(endFrame<1,[endFrame,BufFrames.ir(buf)]);
	duration=(endFrame-startFrame)/s.sampleRate;
	startFrame=Select.kr(rate<0,[startFrame,endFrame]);
	snd=PlayBuf.ar(2,buf,BufRateScale.ir(buf)*rate,1.0,startFrame,1.0);
	snd=snd*EnvGen.ar(Env.linen(0.001,duration-0.01,0.01),doneAction:2);
	Out.ar(out,snd);
}).add;
)

Synth("play",[\buf,c,\startFrame,42794,\duration,60/140*2]);

c.play;
(
var bpm=150;
Routine{
	var breaks=[10897,30340,45870,58877,68810,87599,106927,122597,135667,145570,164672,183900,199231,212243,222340,241422,260492,276052,289258,299030];
	var breakOrder=  [0,1,2,3,4,5,6,7].scramble;
	var rateOrder=[1,1,1,1,1,1,1.25,1,1.neg].scramble;
	var chopOrder=   [0,0,0,0,0,0,0,1,1].scramble;
	var i=1.neg;
	loop {
		var duration,break,breaki,rate,endFrame;
		i=i+1;
		// duration=60/150*(6.rand+1);
		breaki=(breaks.size-1).rand;
		breaki=breakOrder[i%breakOrder.size].postln;
		break=breaks[breaki]-256;
		rate=rateOrder[i%rateOrder.size];//(0.2599*(2.rand))+1;
		endFrame=breaks[breaki+1];
		duration=(endFrame-break)/c.sampleRate;
		// endFrame=break+(duration*c.sampleRate);
		endFrame=endFrame-((chopOrder[i%chopOrder.size])*(60/150/8*c.sampleRate));
		//rate=rate-(2.rand*2);
		// rate=(0.333*(2.rand))+1;
		Synth("play",[\buf,c,\startFrame,break,\endFrame,endFrame,\rate,rate]);
		duration.wait;
	}
}.play;
)

c.sampleRate
Scale