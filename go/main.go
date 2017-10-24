package main

import (
    "log"
    "net/http"
    "time"
    "io/ioutil"
    "io"
    "strings"
    //"regexp"
    "fmt"
)

func main() {
    // create an HTTP Client with a sane timeout.
    var http_client = &http.Client{
      Timeout: time.Second * 10,
    }

    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {

        // grab parameters from query string.
	target_sarray, _ := r.URL.Query()["target"]
	keyword_sarray, _ := r.URL.Query()["keyword"]
	target := strings.Join(target_sarray, "")
	keyword := strings.Join(keyword_sarray, "")

	// connect to target uri and fetch the body.
	resp, _ := http_client.Get(target)
	defer resp.Body.Close()

        body_bytes, _ := ioutil.ReadAll(resp.Body)
	body := string(body_bytes)

	var keyword_found = strings.Contains(body, keyword)
	var found = "false"
	if keyword_found {
	    found = "true"
	}

	// log to stdout.
        fmt.Printf("found=%q, keywork=%q, uri=%q\n", found, keyword, target)

	// return true or false over HTTP.
        io.WriteString(w, found)
    })

    fmt.Println("listening on 0.0.0.0:8888")
    log.Fatal(http.ListenAndServe(":8888", nil))
}
