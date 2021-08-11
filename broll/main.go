package main

import (
	"fmt"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/blang/mpv"
	"github.com/hypebeast/go-osc/osc"
)

type MoviePlayer struct {
	Duration        float64
	c               *mpv.Client
	secondsNoSignal int
	paused          bool
}

var moviePlayerIndex map[string]int
var moviePlayers []MoviePlayer
var mu sync.Mutex

func New(fnameFlac string) (err error) {
	fname := strings.Replace(fnameFlac, ".flac", ".mp4", 1)
	if _, err = os.Stat(fname); os.IsNotExist(err) {
		return
	}
	mu.Lock()
	defer mu.Unlock()

	ind := len(moviePlayers)
	moviePlayerIndex[fnameFlac] = len(moviePlayers)
	moviePlayers = append(moviePlayers, MoviePlayer{})
	socket := fmt.Sprintf("/tmp/mpvsocket%d", ind)

	cmd := exec.Command("mpv", "--idle", "--input-ipc-server="+socket)
	go func() {
		b, _ := cmd.CombinedOutput()
		fmt.Println(b)
	}()
	time.Sleep(500 * time.Millisecond)

	ipcc := mpv.NewIPCClient(socket) // Lowlevel client
	moviePlayers[ind].c = mpv.NewClient(ipcc)
	moviePlayers[ind].c.Loadfile(fname, mpv.LoadFileModeReplace)
	time.Sleep(1 * time.Second)
	moviePlayers[ind].c.SetPause(true)
	moviePlayers[ind].paused = true
	moviePlayers[ind].Duration, err = moviePlayers[ind].c.Duration()
	if err != nil {
		panic(err)
	}
	fmt.Println(moviePlayers[ind].Duration)
	go func() {
		for {
			time.Sleep(1 * time.Second)
			moviePlayers[ind].secondsNoSignal++
			if moviePlayers[ind].secondsNoSignal == 3 {
				moviePlayers[ind].c.SetPause(true)
				moviePlayers[ind].paused = true
			}
		}
	}()

	return
}

func main() {
	moviePlayerIndex = make(map[string]int)
	addr := "127.0.0.1:12345"
	d := osc.NewStandardDispatcher()
	d.AddMsgHandler("/pos", func(msg *osc.Message) {
		foo := strings.Fields(msg.String())
		fmt.Println(foo)
		if len(foo) == 4 {
			mu.Lock()
			ind, ok := moviePlayerIndex[foo[2]]
			mu.Unlock()
			if !ok {
				New(foo[2])
				return
			}
			pos, err := strconv.ParseFloat(foo[3], 64)
			if err == nil {
				moviePlayers[ind].secondsNoSignal = 0
				if moviePlayers[ind].paused {
					moviePlayers[ind].c.SetPause(false)
				}
				fmt.Println("seeking", fmt.Sprintf("%2.4f", pos*moviePlayers[ind].Duration))
				moviePlayers[ind].c.Exec("seek", fmt.Sprintf("%2.4f", pos*moviePlayers[ind].Duration), mpv.SeekModeAbsolute)
			}
		}
	})

	server := &osc.Server{
		Addr:       addr,
		Dispatcher: d,
	}
	server.ListenAndServe()
}
