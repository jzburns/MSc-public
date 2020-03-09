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

func getIndex(w http.ResponseWriter, req *http.Request) {

	// once in error always in error
	if intErr == true {
		e := errors.New("Internal Server error")
		http.Error(w, e.Error(), 500)
		return
	}

	filename := "index.html"
	num := rand.Intn(100)
	if num < 2 {
		log.Fatalf("Server Error. Core Dumpedi [%d]", num)
		os.Exit(1)
	} else if num < 20 {
		e := errors.New("Internal Server error")
		http.Error(w, e.Error(), 500)
		intErr = true
		return
	} else if num < 30 {
		filename = "error.html"
	}
	html, err := ioutil.ReadFile(filename)
	if err != nil {
		log.Fatalf("unable to read file: %v", err)
	}
	fmt.Fprintf(w, string(html[:]))
}

func main() {

	http.HandleFunc("/", getIndex)

	// listen and serve
	fmt.Println("Listening...")
	http.ListenAndServe(":8080", nil)
	fmt.Println("Yes Done...")
}
