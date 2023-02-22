(
~transformer1 = 'dominateX';
~transformer2 = 'dominateY';
~transformer3 = 'dominateZ';
~sndbuf = Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/internet_archive_downloads/aporee_1715_2463/forestwalk.ogg");
)
~sndbuf
~sndbuf.play;


// read a whole sound into memory
// remember to free the buffer later!
// (boot the server, if you haven't!)
~sndbuf = Buffer.readChannel(s, Atk.userSoundsDir ++ "/b-format/Hodges-Purcell.wav",0,-1,0);
~sndbuf = Buffer.read(s, Atk.userSoundsDir ++ "/b-format/Courville-Dialogue.wav")
~sndbuf = Buffer.read(s, Atk.userSoundsDir ++ "/b-format/Leonard-Orfeo_Trio.wav")


(
{
    var sig;                            // audio signal
    var azim;                           // azimuth control


    // display transformer & decoder
    "Ambisonic transforming via % transformer".format(~transformer).postln;
    "Ambisonic decoding via % decoder".format(~decoder.kind).postln;


    // ------------------------------------------------------------
    // test sig
	sig = Mix.new(PlayBuf.ar(2, ~sndbuf, BufRateScale.kr(~sndbuf), loop:1));   // soundfile

    // ------------------------------------------------------------
    // transform
	sig = FoaTransform.ar(sig, ~transformer1, SinOsc.kr(1/1.5).range(-6,6));
	sig = FoaTransform.ar(sig, ~transformer2, SinOsc.kr(1/2.5).range(-6,6));
	sig = FoaTransform.ar(sig, ~transformer2, SinOsc.kr(1/3.5).range(-6,6));
	// sig = FoaTransform.ar(sig, ~transformer3, MouseY.kr(pi/2, 0));
	// sig = FoaTransform.ar(sig, ~transformer4,MouseX.kr(pi, -pi));

    // ------------------------------------------------------------
    // decode (via ~renderDecode)
    ~renderDecode.value(sig, ~decoder)

}.scope;
)