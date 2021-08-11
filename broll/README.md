first install `supercollider`, `mpv`, `ffmpeg`, `youtube-dl`, `Go` then

download youtube video

```
youtube-dl https://archive.org/details/59034VoyageToTheOceanOfStorms
```

convert youtube video to flac + mp4

```
ffmpeg -y -i <downloaded> -c copy -an <anyname>.mp4
ffmpeg -y -i <downloaded> <anyname>.flac
```

start golang server

```bash
go run main.go
```

start SuperCollider and run clip. SuperCollider plays audio, but go server controls video with mpv.

