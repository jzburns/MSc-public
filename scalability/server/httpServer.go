package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"math"
	"net"
	"net/http"
	"os/exec"
	"time"
)

var operationDone chan bool
var channelState = "STOPPED"

func getIndex(w http.ResponseWriter, req *http.Request) {
	html, err := ioutil.ReadFile("index.html")
	if err != nil {
		log.Fatalf("unable to read file: %v", err)
	}
	fmt.Fprintf(w, string(html[:]))
}

func getServerState(w http.ResponseWriter, req *http.Request) {
	type respJSON struct {
		Hostname string
		IPs      []string
		ChannelState string
		Uptime string
	}

	resp := respJSON{}
	resp.Hostname = "test"
	resp.ChannelState = channelState

	// get the uptime for the server that served this page
	out, err := exec.Command("uptime").Output()
	resp.Uptime = string(out[:])

	ifaces, _ := net.Interfaces()

	for _, i := range ifaces {
		addrs, _ := i.Addrs()
		// handle err
		for _, addr := range addrs {
			var ip net.IP
			switch v := addr.(type) {
			case *net.IPNet:
				ip = v.IP
			case *net.IPAddr:
				ip = v.IP
			}
			resp.IPs = append(resp.IPs, ip.String())
		}
	}
	js, err := json.Marshal(resp)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.Write(js)
	fmt.Printf("IPs returned....\n")
}

func startLoadTest(w http.ResponseWriter, req *http.Request) {
	fmt.Printf("starting load test now....\n")
	if 	channelState == "RUNNING" {
		return
	}

	// collect the IP info for the caller
	getServerState(w, req)

	operationDone = make(chan bool)
	channelState = "RUNNING"
	go func() {
		defer func() {
			// do teardown work
			fmt.Printf("load test over....\n")
			channelState = "STOPPED"
		}()
		for {
			select {
			default:
				// do something here periodically check for stop signal
				for i := 0; i < 100000; i++ {
						q := math.Sqrt(float64 (time.Now().Unix()))
						q++
				}
			case <-operationDone:
				fmt.Printf("===> stopping load test now....\n")
				return
			}
		}
	}()
}

func stopLoadTest(w http.ResponseWriter, req *http.Request) {
	fmt.Printf("stopping load test now....\n")
	close(operationDone)
	getServerState(w, req)
}

func getTestState(w http.ResponseWriter, req *http.Request) {
	type respJSON struct {
		State string
	}

	resp := respJSON{}
	resp.State = channelState

	js, err := json.Marshal(resp)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.Write(js)
}

func main() {

	http.HandleFunc("/", getIndex)
	http.HandleFunc("/start_load_test", startLoadTest)
	http.HandleFunc("/stop_load_test", stopLoadTest)
	http.HandleFunc("/get_ip_addr", getServerState)
	http.HandleFunc("/get_test_state", getTestState)

	// listen and serve
	fmt.Println("Listening...")
	http.ListenAndServe(":8080", nil)
	fmt.Println("Yes Done...")
}
