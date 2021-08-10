package main

import (
	"flag"
	"io"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/hypebeast/go-osc/osc"
	log "github.com/schollz/logger"
)

var flagHost = flag.String("host", "127.0.0.1", "host address to the osc server")
var flagPort = flag.Int("port", 57120, "port of the osc server")

func main() {
	flag.Parse()

	// run client in background
	go func() {
		client := osc.NewClient(*flagHost, *flagPort)
		for {
			log.Debug("sending msg")
			time.Sleep(1 * time.Second)
			msg := osc.NewMessage("/down")
			msg.Append("down.wav")
			client.Send(msg)
			// log.Debug("attempting download")
			// errDownload := downloadFile("down.wav", "test")
			// if errDownload == nil {
			// 	msg := osc.NewMessage("/osc/down")
			// 	msg.Append(true)
			// 	client.Send(msg)
			// }
		}
	}()

	// run server
	addr := "127.0.0.1:8765"
	d := osc.NewStandardDispatcher()
	// receive a message to upload the file
	d.AddMsgHandler("/up", func(msg *osc.Message) {
		foo := strings.Fields(msg.String())
		log.Debug(msg.String())
		log.Debugf("uploading %s", foo[len(foo)-1])
	})

	server := &osc.Server{
		Addr:       addr,
		Dispatcher: d,
	}
	server.ListenAndServe()
}

func uploadFile(fname, duct string) (err error) {
	f, err := os.Open(fname)
	if err != nil {
		log.Error(err)
		return
	}
	defer f.Close()
	req, err := http.NewRequest("POST", "https://duct.schollz.com/"+duct+"?pubsub=true", f)
	if err != nil {
		log.Error(err)
		return
	}
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		log.Error(err)
		return
	}
	defer resp.Body.Close()

	return
}

func downloadFile(fname, duct string) (err error) {
	resp, err := http.Get("https://duct.schollz.com/" + duct)
	if err != nil {
		log.Error(err)
		return
	}
	defer resp.Body.Close()

	out, err := os.Create(fname)
	if err != nil {
		log.Error(err)
		return
	}
	defer out.Close()
	_, err = io.Copy(out, resp.Body)
	return
}
