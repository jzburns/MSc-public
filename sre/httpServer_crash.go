/*
* (C) John Burns 2020
* All rights Reserved
* For non-commercial academic use only
*/
package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"net/http"
	"math/rand"
	"errors"
)

// keep the state between calls
var intErr = false

// HTTP / call back
// can do 4 things:
// 0.02 chance to core dump
// 0.02-0.20 chance for internal server error
// 0.21-0.50 chance for NPE
// 0.31 - 1.0 the chance for OK
func getIndex(w http.ResponseWriter, req *http.Request) {

	// would be useful to get the IP here too:
	log.Println("Processing GET request")
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
	num := rand.Intn(100)
	if num < 2 {
		log.Fatalf("Server Error. Core Dumped [%d]", num)
		os.Exit(1)
	} else if num < 20 {
		log.Print("Internal Server Error [500]")
		e := errors.New("Internal Server error")
		http.Error(w, e.Error(), 500)
		// now we're stuck
		intErr = true
		return
	} else if num < 50 {
		log.Print("Null Pointer Exception")
		filename = "error.html"
	}
	html, err := ioutil.ReadFile(filename)
	if err != nil {
		log.Fatalf("unable to read file: %v", err)
	}
	fmt.Fprintf(w, string(html[:]))
}

func main() {
	port := ":8080"
	// register the call back
	http.HandleFunc("/", getIndex)

	// listen and serve
	fmt.Printf("Listening on port %s\n", port)
	http.ListenAndServe(port, nil)
}
