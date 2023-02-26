(
// startup and add 3 files to play
s.waitForBoot({
	a=FoldersOfSound.new(s);
	a.playFolder(thisProcess.nowExecutingPath.dirname++"/internet_archive_downloads",3);
});
)

// at anytime you can run these lines to add/remove samples:

// add 1
a.playFolder(thisProcess.nowExecutingPath.dirname++"/internet_archive_downloads",1);

// remove 1
a.remove(1)


