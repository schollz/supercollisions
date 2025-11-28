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

l.setMixKick(0,1,0.5);
l.setMixSnare(0,1,0);
l.setMixCH(0.5,1);
(
Routine{
	5.do({
		l.playKick(100,4,0,1,20000,0,0,0);
		1.wait;
	});
}.play;
)
(
x=Routine{
	var j = 0;
	var j2 = 0;
	var jhat = 0;
	~play_snare = "x-";
	~play_kick = "x-------x---x-x-";
	~accent_snare = "x--x--x--x-x-x-";
	~accent_kick = "x---x-x---";
	~play_hat = "x-";
	~accent_hat = "x";
	inf.do({ arg i;
		var play_kick = ~play_kick[i.mod(~play_kick.size)]==$x;
		var accent_kick = false;
		var velocity_kick = 70;
		var play_hat = ~play_hat[i.mod(~play_hat.size)]==$x;
		var accent_hat = false;
		var velocity_hat = 70;
		var play_snare = ~play_snare[i.mod(~play_snare.size)]==$x;
		var accent_snare = false;
		var velocity_snare = 70;
		if (play_snare, {
			j = j + 1;
			accent_snare = ~accent_snare[j.mod(~accent_snare.size)]==$x;
		});
		if (accent_snare,{
			velocity_snare = 120;
		});
		if (play_snare,{
			l.playSnare(velocity_snare,1,0,1,20000,0,0,0);
		});
		if (play_kick, {
			j2 = j2 + 1;
			accent_kick = ~accent_kick[j2.mod(~accent_kick.size)]==$x;
		});
		if (accent_kick,{
			velocity_kick = 120;
		});
		if (play_kick,{
			l.playKick(velocity_kick,1,0,1,20000,0,0,0);
		});

		if (play_hat, {
			jhat = jhat + 1;
			accent_hat = ~accent_hat[jhat.mod(~accent_hat.size)]==$x;
		});
		if (accent_hat,{
			velocity_hat = 120;
		});
		if (play_hat,{
			l.playCH(velocity_hat,2,0,1,20000,0,0,0);
		});

		(60/150/8).sleep;
	});
}.play;
)
~play_hat="x-x-x-";
~accent_hat="x------x-x--x-x-x-x-x-x-";
~play_kick = "x-------x-------";
~accent_kick = "x-x-xx";
~play_snare = "x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-xxxx-xx-x-";
~accent = "x--x--x--x-x-x-xx-xx-x--x--xx-";
x.stop;
