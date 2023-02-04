(
s.waitForBoot({
	Routine {
		b=Barcode.new(Server.default);
		// barcode.play(1,1);
		// barcode.record(1,1);
		// 2.wait;
		// barcode.play(1,1);
		b.load(1,"/home/zns/Documents/supercollisions/starlids.wav");
		b.play(1,1,1,1);
		b.play(1,2,0.5,1.5);
		b.play(1,3,2,0.25);
		b.play(1,4,0.25,2);
		b.play(1,5,4,0.125);
	}.play;
});
)
