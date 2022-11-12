(
 var clock, sf, cut;

 TempoClock.default.tempo_(180/60);
 clock = ExternalClock(TempoClock.default);
 clock.play;

 sf= BBCutBuffer(thisProcess.nowExecutingPath.dirname++"BBCut/sounds/break",8);

 Routine.run({
  s.sync; // this tells the task to wait

  cut = BBCut2(CutBuf3(sf, 0.4), BBCutProc11(8, 4, 2, 2, 0.2)).play(clock);

  30.wait; //  // let things run for 30 seconds

  cut.stop;
  cut.free;
 })
)