package main

import (
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/blang/mpv"
	"github.com/hypebeast/go-osc/osc"
)

// type MoviePlayer struct {
// 	Duration        float64
// 	mpvc            *mpv.Client
// 	secondsNoSignal int
// 	pause           bool
// }

// var moviePlayerIndex map[string]int
// var moviePlayers []MoviePlayer

// func New(fname string) (mp MoviePlayer, err error) {
// 	if _, err = os.Stat(fname); os.IsNotExist(err) {
// 		return
// 	}
// 	// run a new instance of mpv

// 	return
// }

var duration float64
var mpvc *mpv.Client
var secondsNoSignal int
var paused bool

func mpvrun() (err error) {
	ipcc := mpv.NewIPCClient("/tmp/mpvsocket") // Lowlevel client
	mpvc = mpv.NewClient(ipcc)                 // Highlevel client, can also use RPCClient
	mpvc.Loadfile("apollo.mp4", mpv.LoadFileModeReplace)
	time.Sleep(1 * time.Second)
	mpvc.SetPause(true)
	paused = true
	duration, err = mpvc.Duration()
	if err != nil {
		panic(err)
	}
	fmt.Println(duration)
	go func() {
		for {
			time.Sleep(1 * time.Second)
			secondsNoSignal++
			if secondsNoSignal == 3 {
				mpvc.SetPause(true)
				paused = true
			}
		}
	}()
	return
}

func main() {
	mpvrun()
	addr := "127.0.0.1:12345"
	d := osc.NewStandardDispatcher()
	d.AddMsgHandler("/pos", func(msg *osc.Message) {
		secondsNoSignal = 0
		foo := strings.Fields(msg.String())
		fmt.Println(foo)
		if len(foo) == 3 {
			pos, err := strconv.ParseFloat(foo[2], 64)
			if err == nil {
				seek(pos)
			}
		}
	})

	server := &osc.Server{
		Addr:       addr,
		Dispatcher: d,
	}
	server.ListenAndServe()
}

func seek(pos float64) (err error) {
	if paused {
		mpvc.SetPause(false)
	}
	fmt.Println("seeking", fmt.Sprintf("%2.4f", pos*duration))
	mpvc.Exec("seek", fmt.Sprintf("%2.4f", pos*duration), mpv.SeekModeAbsolute)

	return
}
