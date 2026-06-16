package log

import (
	"fmt"
	ip "kavi-kasir/pkg/ip"
	"net/http"
	"time"
)

func Log(message, level string, r *http.Request) {
	ip := ip.ClientIP(r)
	t := time.Now()

	red := "\033[31m"
	green := "\033[32m"
	yellow := "\033[33m"
	reset := "\033[0m"
	purple := "\033[35m"
	blue := "\033[34m"

	var log string
	switch level {
	case "INFO":
		log = green + "INFO" + reset
	case "ERROR":
		log = red + "ERROR" + reset
	case "WARN":
		log = yellow + "WARN" + reset
	}

	var logColor string
	switch r.Method {
	case http.MethodPatch:
		logColor = purple + "PATCH" + reset
	case http.MethodPut:
		logColor = blue + " PUT " + reset
	case http.MethodDelete:
		logColor = red + "DELETE" + reset
	case http.MethodGet:
		logColor = green + "  GET  " + reset
	case http.MethodPost:
		logColor = yellow + " POST " + reset
	}

	fmt.Println("[ LOG ] ", log, "--- Client IP:[", ip, "] Path:[", logColor, r.URL.String(), "] Time:[", t.Format("2006-01-02 15:04:05"), "] Message:[", message, "]")
}
