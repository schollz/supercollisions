(
SynthDef("chord",{
	arg note=60,amp=0.5,attack=0.01,decay=2,t_trig=1,mod1=0.5,mod2=0.5;
	var snd, env,detuning;
	var envSign=Select.kr((attack>decay),[1,1.neg]);
	detuning=LinExp.kr(mod1,0,1,0.001/10,0.001*10).poll;
	snd= Splay.arFill(2, { |i|
		var hz=(note+Rand(-0.05,0.05)).midicps;
		var osc = Mix.ar(SawDPW.ar(hz * 2.pow(detuning * [-3, 0, 3])));
		var filter = LPF.ar(osc, LinExp.kr(LFTri.kr(Rand(0.2,4*(mod2-0.5)+0.3),Rand(0,2)),-1,1,200,1500));
		filter * 0.06;
	}, levelComp: false);
	env = EnvGen.ar(Env.perc(attack,decay*2,amp,[4*envSign,-2]),t_trig,doneAction:2);
	snd = snd * env;
	snd=Select.ar(mod2>0.5,[snd,snd*LFPar.ar((mod2-0.5).range(1,7))]);
	snd=HPF.ar(snd,80);
	snd=LeakDC.ar(snd);
	Out.ar(0,snd);
}).add;
)

(
x=Synth("chord",[\note,60-12,\mod2,0.8]);
y=Synth("chord",[\note,64,\mod2,0.9]);
z=Synth("chord",[\note,67-12,\mod2,0.8]);
)
(
x.set(\t_trig,1);
y.set(\t_trig,1);
z.set(\t_trig,1);
)
(
x.set(\t_trig,0);
y.set(\t_trig,0);
z.set(\t_trig,0);
)

(
{
	EnvGen.ar(Env.perc(0.5,0.5,1,[4,2]))
}.plot(1)
)