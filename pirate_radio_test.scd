s.boot;

p=PirateRadio.new(s,"~/Music")

// set a radio station to 94.7 +/- 1
p.setBand(0,94.7,1);

// set dial to 94.7
p.setDial(94.7);