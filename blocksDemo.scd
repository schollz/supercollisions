(
s.waitForBoot({
	~blocks = Blocks.new(s);
	s.sync;
	~blocks.gui;
});
)
