package main

import (
	"encoding/json"
	"net/http"

	"bytes"
	"fmt"
	"github.com/apex/go-apex"
	"github.com/apex/go-apex/proxy"
	"log"
	"os"
)

type message struct {
	Hello string `json:"hello"`
}

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/", HttpService)
	mux.HandleFunc("/sample", HttpService)

	if os.Getenv("APEX") == "" {
		log.Println("starting up with local httpd")
		log.Fatal(http.ListenAndServe(":8080", mux))
	} else {
		log.Println("starting up with API Gateway and lambda")
		apex.Handle(proxy.Serve(mux))
	}
}

func HttpService(w http.ResponseWriter, r *http.Request) {
	bodybuf := new(bytes.Buffer)
	bodybuf.ReadFrom(r.Body)
	body := bodybuf.Bytes()

	var m message

	if len(body) == 0 {
		// preset default message
		m.Hello = "Hello, Golang world."
	} else if err := json.Unmarshal(body, &m); err != nil {
		http.Error(w, "something error", http.StatusInternalServerError)
	}

	fmt.Fprintf(w, m.Hello)
}
