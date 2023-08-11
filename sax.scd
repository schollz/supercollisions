(
s.waitForBoot({

	a = Supersax.new(s,"/home/zns/Documents/sax-symphony/lib/samples");
});
)

(
a.note_on(0,0,60,90,0.50);
a.note_on(0,0,72,60,0.50);
a.note_on(0,0,72+7,60,0.90);
a.note_on(0,0,72+11,60,0.20);
)

(
a.note_on(0,0,60,90,0.50);
a.note_on(0,0,72+14,60,0.50);
a.note_on(0,0,72+5,60,0.90);
a.note_on(0,0,72+7,60,0.20);
)