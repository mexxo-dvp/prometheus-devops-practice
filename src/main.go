package main

import (
    "net/http"
    "log"
)

func main() {
    fs := http.FileServer(http.Dir("/html"))
    http.Handle("/", fs)

    log.Println("Server UP on http://localhost:8080")
    err := http.ListenAndServe(":8080", nil)
    if err != nil {
        log.Fatal(err)
    }
}
