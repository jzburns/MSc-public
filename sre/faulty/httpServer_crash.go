/*
* (C) John Burns 2020-2022
* All rights Reserved
* For non-commercial academic use only
* 
* Intermittent Fault Injection Lab
*/
package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"time"
	"os"
	"net/http"
	"math/rand"
	"errors"
)

// keep the error 500 state between calls
// once it fails it keeps failing
var intErr = false
var latency = 0
var logfileName =  "/app/golang.log"

// HTTP / call back
// can do 4 things:
// 0.005 chance to core dump
// 0.021-0.20 chance for internal server error
// 0.21-0.50 chance for Database connection down
// 0.51 - 0.7 the chance for Multi-second latency
// 0.71 - 1.0 the chance for OK
func getBalance(w http.ResponseWriter, req *http.Request) {
	// would be useful to get the IP here too:
	log.Println("Processing GET request")
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	// the default file to load
	filename := "index.html"

	// roll the dice
	num := r.Intn(1000)
	if num < 5 {
		log.Fatalf("ERROR Server Core Dumped [%d]", num)
		os.Exit(1)
	} else if num < 200 {
		log.Print("ERROR Internal Server Error [500]")
		e := errors.New("ERROR Internal Server error")
		http.Error(w, e.Error(), 500)
		return
	} else if num < 500 {
		// if the datanase is not reachable
		// lets tell the user to check back later
		log.Print("ERROR Database Connection Pool Empty")
		filename = "error.html"
	} else if num < 700 {
		// Latency problems...
		latency += r.Intn(500)
		// it gets slower and slower
		time.Sleep(time.Duration(latency) * time.Millisecond)
		log.Printf("WARNING Server Latency is now [%d] Milliseconds", latency)
	}
	// we made it to here so no error
	// now serve the page
	html, err := ioutil.ReadFile(filename)
	if err != nil {
		log.Fatalf("unable to read file: %v", err)
	}
	fmt.Fprintf(w, string(html[:]))
}

// a quick HTTP log viewer
func getLogs(w http.ResponseWriter, req *http.Request) {
        html, err := ioutil.ReadFile(logfileName)
        if err != nil {
                log.Fatalf("unable to read file: %v", err)
        }
        fmt.Fprintf(w, string(html[:]))
}

func main() {
	port := ":8080"
	// register the call backs
	http.HandleFunc("/getbalance", getBalance)
	http.HandleFunc("/getlogs", getLogs)

	f, err := os.OpenFile(logfileName, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		log.Println(err)
	}
	defer f.Close()

	log.SetOutput(f)

	// listen and serve
	fmt.Printf("Listening on port %s\n", port)
	http.ListenAndServe(port, nil)
}
