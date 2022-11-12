b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav"); // remember to free the buffer later.
b=Buffer.read(s,"/home/zns/Documents/supercollisions/CHIME_beatbox_breakbeat_140__beats8_bpm140.wav");
b=Buffer.read(s,"/home/zns/Documents/supercollisions/chords_gmin.wav");

b=Buffer.read(s,"/home/zns/Documents/supercollisions/goalltheway.wav");

(
{
	var wet;
	var snd=PlayBuf.ar(2,b,loop:1);
	var dry=snd;
	dry=dry+PitchShift.ar(dry,pitchRatio:2);
	wet=Greyhole.ar(dry[0],dry[1],decay:80,damping:5500,modulator_depth:1);
	Out.ar(0,MouseX.kr()*snd+((1-MouseX.kr())*wet));
}.play;
)