
(
b=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/Bauld_Break_140_PL__beats8_bpm140.wav");
)
b.play


(
SynthDef("xfadeLoop",{
    arg buf,loopStart=0,loopEnd=1,rate=1.0,cut_fade=0.5,duration=1,direction=1,xfade=0.05;
    var snd, localin_data, readHead_changed, readHead_in, readHead, pos1,pos2,pos1trig,pos2trig,frames,framesStart,framesEnd;

	var line=Line.kr(0,1,duration,doneAction:2);
	rate=rate*BufRateScale.ir(buf)*((loopStart<loopEnd)*2-1);
    frames=BufFrames.ir(buf).poll;
    framesEnd=frames*loopEnd;
    framesStart=frames*loopStart;

    localin_data=LocalIn.ar(2);
    readHead_changed=localin_data[0];
    readHead_in=localin_data[1];
    pos1=Phasor.ar(
        trig:readHead_changed*(1-readHead_in),
        rate:rate,
        start:framesStart,
        end:(rate>0)*frames,
        resetPos:framesStart,
    );
    pos1trig=Trig.ar((pos1>framesEnd)*(1-readHead_in),0.01)*(rate>0);
    pos1trig=pos1trig+(Trig.ar((pos1<framesEnd)*(1-readHead_in),0.01)*(rate<0));
    pos2=Phasor.ar(
        trig:readHead_changed*(readHead_in),
        rate:rate,
        start:framesStart,
        end:(rate>0)*frames,
        resetPos:framesStart,
    );
    pos2trig=Trig.ar((pos2>framesEnd)*readHead_in,0.01)*(rate>0);
    pos2trig=pos2trig+(Trig.ar((pos2<framesEnd)*readHead_in,0.01)*(rate<0));
    readHead=ToggleFF.ar(pos1trig+pos2trig).poll;
    LocalOut.ar([Changed.ar(readHead),readHead]);
    snd=BufRd.ar(2,buf,pos1,interpolation:2);
    snd=SelectX.ar(Lag.ar(readHead,cut_fade),[snd,BufRd.ar(2,buf,pos2,interpolation:2)]);
	snd=RLPF.ar(snd,LinExp.kr(line,1-direction,direction,100,20000),0.707);
	snd=snd*EnvGen.ar(Env.new([0,1,1,0],[xfade,duration-xfade-xfade,xfade],\sine),doneAction:2);
	snd=snd*line;
    snd=Pan2.ar(snd!2,0);
    Out.ar(0,snd);
}).add;
)

(
var xx=b.duration;
var repeats=8;
while ({xx>0.18},{xx=xx/2});
x=Synth("xfadeLoop",[\buf,b,\loopStart,0.1,\loopEnd,0.1+(xx/b.duration),\duration,repeats*xx,\direction,1,\xfade,0.05,\cut_fade,xx/8]);
)

