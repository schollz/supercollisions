(
s.waitForBoot({
	a=FoldersOfSound.new(s);
	a.playFolder(thisProcess.nowExecutingPath.dirname++"/internet_archive_downloads",3);
});
)

// add 1
a.playFolder(thisProcess.nowExecutingPath.dirname++"/internet_archive_downloads",3);

// remove 1
a.remove(1)

