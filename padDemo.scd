(
s.waitForBoot({
	b=Pad.new(s);

	b.gui;

})
)


{EnvGen.ar(Env.perc(1,1,1,[4,4]),timeScale:0.1)}.plot(0.2)