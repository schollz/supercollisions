// requires "Ube.sc" to be put into the Extensions directory
(
s.waitForBoot({
	var pairs;
	// load the ube class
	u=Ube.new(Server.default);

	// load a file
	u.loadTape(tape:1,filename:thisProcess.nowExecutingPath.dirname++"/kalimba.wav");

	// play the tape with lots of players
	pairs=[
		[1, 0], // rate is the first number, db is the second
		[2, -6],
		[0.5, -6],
		[4, -9],
		[0.25, -9],
		[0.125,0],
	];
	pairs.do({ arg v,i;
		u.playTape(tape:1,player:i,rate:v[0],db:v[1],timescale:1.0);
	});

	// show gui
	u.gui;
});
)

// record another tape and play it
u.recordTape(tape:2,seconds:3,recLevel:0.5);
u.playTape(tape:2,player:5,rate:1,db:1,timescale:1.0);

