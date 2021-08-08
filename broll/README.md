download youtube video

convert youtube video to flac + mp4

```
ffmpeg -y -i <downloaded>.webm -c copy -an everything.mp4
ffmpeg -y -i <downloaded>.webm everything.flac
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

