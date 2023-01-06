s=Server.local;
s.options.numOutputBusChannels=4;
s.boot;


(
{
	var snd;
	snd = PanAz.ar(4,SinOsc.ar(220)*0.1,MouseX.kr(-1,1),orientation:0);
	snd = snd + PanAz.ar(4,SinOsc.ar(110)*0.1,MouseX.kr(-1,1),orientation:0.25);
	snd = snd + PanAz.ar(4,SinOsc.ar(880)*0.1,MouseX.kr(-1,1),orientation:0.5);
	snd = snd + PanAz.ar(4,SinOsc.ar(442)*0.1,MouseX.kr(-1,1),orientation:0.75);
	Out.ar(0,snd.poll);
}.play;
)
