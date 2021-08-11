download youtube video

```
youtube-dl https://archive.org/details/59034VoyageToTheOceanOfStorms
```

convert youtube video to flac + mp4

```
ffmpeg -y -i <downloaded>.mp4 -c copy -an apollo.mp4
ffmpeg -y -i <downloaded>.webm apollo.flac
```

start vlc server 

```bash
vlc -I http --http-password 123
```

actually start mpv server

```bash
mpv --idle --input-ipc-server=/tmp/mpvsocket
```

start golang server

```bash
go run main.go
```

start SuperCollider and run clip. SuperCollider plays audio, but controls video.

