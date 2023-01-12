// fogthorn
(
{
	arg note=30;
	var snd;
	snd = SinOsc.ar((note+[-0.02,0.02]).midicps);
	// 31 or 48
	snd = snd + SinOsc.ar((note+TChoose.kr(Impulse.kr(0),[12,24,36,19,31,43])+[0.01,0.02]).midicps,
		mul:EnvGen.kr(Env.new([0,1,0],[0.2,0.9],curve:[3,0]),1)
	);
	snd = FreeVerb2.ar(snd[0],snd[1],0.4,0.5,0.4);
	snd = (snd*EnvGen.kr(Env.new([1,12,9],[0.05,0.4],curve:[3,0]),1)).softclip;
	snd = RLPF.ar(snd,(note+EnvGen.kr(Env.new([note+24,note+60,note+12],[0.1,4],curve:[3,0]),1)).midicps,0.707);
	snd = snd * EnvGen.ar(Env.perc(0.01,5),doneAction:2);
	Out.ar(0,snd*0.5);
}.play;

)
		
		
(
{
	EnvGen.kr(Env.new([0,1,0],[0.05,0.05],curve:[3,0]),1)
	}.plot(0.1)
	)