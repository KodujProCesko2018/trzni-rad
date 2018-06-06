package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"

	"github.com/rakyll/statik/fs"
	"github.com/tealeg/xlsx"
	_ "server/statik"
)

const (
	xlsxFileName = "trzni-rad.xlsx"
	geoFileName  = "trzni-rad.geojson"
)

var zadostFieldName = []string{
	"typ", "typ_ostatni", "ulice", "cp", "co", "mestska_cast",
	"parcelni_cislo", "velikost", "druh_zarizeni", "doba", "trasa",
	"druh_zbozi", "termin", "jmeno", "firma", "adresa", "ico", "tel",
	"polygon",
}
var zadostFieldTitle = []string{
	"Návrh na zařazení", "Ostatní", "Ulice", "č.p.", "č.o", "Městská část",
	"Parcelní číslo", "Velikost místa", "Druh prodejního zařízení", "Prodejní doba",
	"Trasa pro pojízdný prodej (vymezená názvy ulic)", "Druh prodávaného zboží (sortiment) nebo poskytované služby",
	"Termín provozu (např.:, příležitostně, celoročně, od 1.5.-31.10, )", "Příjmení a jméno",
	"Obchodní firma/název", "Sídlo/doručovací adresa", "Identifikační číslo", "Telefon/elektronická adresa",
	"GEO polygon",
}

var statikFS http.FileSystem

func readGeoJSON(w http.ResponseWriter, r *http.Request) {
	var (
		content, err = ioutil.ReadFile(geoFileName)
	)
	if err != nil {
		log.Printf("Non-existing file \"%s\"!\n", geoFileName)
		w.WriteHeader(http.StatusNotFound)
		return
	}
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.Write(content)
	w.WriteHeader(http.StatusOK)
}

func registerMarket(w http.ResponseWriter, r *http.Request) {
	var (
		file, err = xlsx.OpenFile(xlsxFileName)
	)
	if err != nil {
		file = xlsx.NewFile()
		file.AddSheet("zadosti")
		row := file.Sheets[0].AddRow()
		for title := range zadostFieldTitle {
			cell := row.AddCell()
			cell.Value = zadostFieldTitle[title]
		}
	}
	defer file.Save(xlsxFileName)

	sheet := file.Sheets[0]
	row := sheet.AddRow()
	for key := range zadostFieldName {
		cell := row.AddCell()
		cell.Value = r.PostFormValue(zadostFieldName[key])
	}
	http.Redirect(w, r, "/index.html", http.StatusFound)
}

func main() {
	var (
		muxer = http.NewServeMux()
		host  string
		port  int
		debug bool
		err   error
	)
	flag.StringVar(&host, "host", "localhost", "Hostname to listen at (default localhost)")
	flag.IntVar(&port, "port", 8080, "Port to listen to (default 8080)")
	flag.BoolVar(&debug, "debug", false, "Debug server statics from local folder")
	flag.Parse()

	statikFS, err = fs.New()
	if err != nil {
		log.Fatal(err)
	}

	if debug == true {
		log.Println("Serving from File System folder pages/")
		muxer.Handle("/", http.FileServer(http.Dir("pages/")))
	} else {
		log.Println("Serving embedded static! Did you update them by $ statik -src <project>/pages ?")
		muxer.Handle("/", http.FileServer(statikFS))
	}
	muxer.HandleFunc("/geojson", readGeoJSON)
	muxer.HandleFunc("/zadost", registerMarket)

	listen := fmt.Sprintf("%s:%d", host, port)
	log.Println("Listening at " + listen)
	http.ListenAndServe(listen, muxer)
}
