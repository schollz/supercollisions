(
SynthDef("xfadeLoop",{
    arg buf,loopStart=0,loopEnd=1,rate=1.0,cut_fade=0.2;
    var snd, localin_data, readHead_changed, readHead_in, readHead, pos1,pos2,pos1trig,pos2trig,frames,framesStart,framesEnd;

    loopStart=Lag.kr(MouseX.kr());
    loopEnd=Lag.kr(MouseY.kr());
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
    snd=Pan2.ar(snd!2,0);
    Out.ar(0,snd);
}).add;
)

b = Buffer.read(s, "/home/zns/Documents/supercollisions/beats16_bpm150_Ultimate_Jack_Loops_014__BPM_150_.wav"); // remember to free the buffer later.
x=Synth("xfadeLoop",[\buf,b]);
