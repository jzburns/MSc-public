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

// HTTP / call back
// can do 4 things:
// 0.02 chance to core dump
// 0.021-0.20 chance for internal server error
// 0.21-0.50 chance for Database connection down
// 0.51 - 0.7 the chance for Multi-second latency
// 0.71 - 1.0 the chance for OK
func getBalance(w http.ResponseWriter, req *http.Request) {
	// would be useful to get the IP here too:
	log.Println("Processing GET request")
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	// once in error always in error
	if intErr == true {
		e := errors.New("Internal Server error")
		http.Error(w, e.Error(), 500)
		log.Print("Internal Server Error [500]")
		return
	}
	// the default file to load
	filename := "index.html"

	// roll the dice
	num := r.Intn(100)
	if num < 2 {
		log.Fatalf("ERROR Server Core Dumped [%d]", num)
		os.Exit(1)
	} else if num < 20 {
		log.Print("ERROR Internal Server Error [500]")
		e := errors.New("ERROR Internal Server error")
		http.Error(w, e.Error(), 500)
		// now we're stuck
		intErr = true
		return
	} else if num < 50 {
		// if the datanase is not reachable
		// lets tell the user to check back later
		log.Print("ERROR Database Not Reachable")
		filename = "error.html"
	} else if num < 70 {
		// Latency problems...
		latency += r.Intn(500)
		// it gets slower and slower
		time.Sleep(time.Duration(latency) * time.Millisecond)
		log.Printf("WARNING Server Latency is now [%d] Milliseconds", latency)
	}
	// we made it to here so no error
	// we made it to here so no error
	// now serve the page
	html, err := ioutil.ReadFile(filename)
	if err != nil {
		log.Fatalf("unable to read file: %v", err)
	}
	fmt.Fprintf(w, string(html[:]))
}

func main() {
	port := ":8080"
	// register the call back
	http.HandleFunc("/getbalance", getBalance)

	// listen and serve
	fmt.Printf("Listening on port %s\n", port)
	http.ListenAndServe(port, nil)
}
