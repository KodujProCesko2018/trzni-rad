package main

import (
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
)

func ok(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, "OK!")
}

func readGeoJSON(w http.ResponseWriter, r *http.Request) {
	var (
		content, err = ioutil.ReadFile("geo.json")
	)
	if err != nil {
		log.Println("Non-existing file \"geo.json\"!")
		w.WriteHeader(http.StatusNotFound)
		return
	}
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.Write(content)
	w.WriteHeader(http.StatusOK)
}

func registerMarket(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, "TBD!")
}

func main() {
	var (
		muxer = http.NewServeMux()
		host  string
		port  int
	)
	flag.StringVar(&host, "host", "localhost", "Hostname to listen at (default localhost)")
	flag.IntVar(&port, "port", 8080, "Port to listen to (default 8080)")

	muxer.HandleFunc("/", ok)
	muxer.HandleFunc("/geojson", readGeoJSON)
	muxer.HandleFunc("/zadost", registerMarket)

	listen := fmt.Sprintf("%s:%d", host, port)
	log.Println("Listening at " + listen)
	http.ListenAndServe(listen, muxer)
}
