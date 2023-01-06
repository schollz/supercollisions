(
~numIRs = 2;
~fftsize = 4096;
s.waitForBoot {
	var irs, irbuffs, bufsizes, nextmod, numSamples;
	nextmod = 200;
	numSamples = 40000 ;

	/* an array of multiple IRs */
	irs = ~numIRs.collect{ arg nth;
		// nth is here not used, but can be useful to scale decay time.
		[0] ++ 0.dup(100) ++ Array.fill(
			numSamples, { arg i;
				(i%nextmod==0).if
				{
					nextmod= rrand(20, 200);
					(i.asFloat/numSamples).squared * 0.3
				} {
					0
				}
			}
		)
	};
	{ irs.plot }.defer; // to show irs.

	/* an array of buffers. */
	irbuffs = ~numIRs.collect{ arg i; Buffer.loadCollection(s, irs[i]) };
	irbuffs.postln; // to show irbuffs info.
	s.sync;

	bufsizes= irbuffs.collect{ |nth|PartConv.calcBufSize(~fftsize, nth) };
	~irSpctrms = bufsizes.collect{ arg size, i;
		Buffer
		.alloc(s, size, 1)
		.preparePartConv(irbuffs[i], ~fftsize)
	};
	s.sync;

	~numIRs.do{|i| irbuffs[i].free}
}
)

(
fork{
//	~target= Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
	~target=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/pad_bpm120_beats64.wav");

	s.sync;
	{
		var in, krnl;
		in= PlayBuf.ar(1, ~target, loop:1);

		/* an array of multiple instances of PartConv */
		krnl= ~numIRs.collect{ arg i;
			PartConv.ar(in, ~fftsize, ~irSpctrms[i].bufnum, 0.2)};
		// By iterating, each PartConv processes a mono-channel buffer in the array ~irSpctrms.

		Out.ar(0,krnl);
	}.play
}
)