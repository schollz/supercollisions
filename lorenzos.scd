(
s.waitForBoot({
	l=LorenzosDrums.new(Server.default,"/home/zns/Documents/supercollisions/lorenzos-drums/");
	// Routine{
	// 	var vels=[60,60,40,60,60,40,60,60];
	// 	var i=1.neg;
	// 	inf.do({
	// 		i=i+1;
	// 		l.playSnare(vels[i.mod(vels.size)]+10.rand,2,0,1,20000,0,0,0);
	// 		0.125.sleep;
	// 	});
	// }.play;

});
)

l.setMixKick(1,0.25,0.5);
l.setMixSnare(0,1,0);
(
Routine{
	5.do({
		l.playKick(100,4,0,1,20000,0,0,0);
		1.wait;
	});
}.play;
)
(
Routine{
	8.do({
		(4.rand/4).wait;
		l.playSnare(80,1,0,1,20000,0,0,0);
	});
	5.do({ arg i;
		l.playSnare(80,i/5+0.5,0,1,20000,0,0,0);
		(0.125/4).sleep;
	});
	l.playSnare(120,2,0,1,20000,0,0,0);
}.play;
)
