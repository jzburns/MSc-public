/*
* (C) John Burns 2020
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
	"net/http"
	"os"
)

// keep the error 500 state between calls
// once it fails it keeps failing
var intErr = false
var latency = 0
var logfileName = "/app/golang.log"

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
	// the default file to load
	filename := "index.html"
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
	port := ":80"
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
