package response

import (
	"encoding/json"
	"kavi-kasir/internal/model"
	logging "kavi-kasir/pkg/logging"
	"net/http"
)

func Message(message string, log string, ty string, code int, w http.ResponseWriter, r *http.Request) {
	var s bool

	switch ty {
	case "INFO":
		s = true
	case "WARN":
		s = false
	case "ERROR":
		s = false
	}

	res, _ := json.Marshal(model.ResponseMessage{Status: code, Success: s, Message: message})
	logging.Log(log, ty, r)
	w.WriteHeader(code)
	w.Write(res)
}

func Message2(message string, reference model.ReferenceResult, log string, ty string, code int, w http.ResponseWriter, r *http.Request) {
	var s bool

	switch ty {
	case "INFO":
		s = true
	case "WARN":
		s = false
	case "ERROR":
		s = false
	}

	res, _ := json.Marshal(model.ResponseMessage{Status: code, Success: s, Message: message, Reference: reference})
	logging.Log(log, ty, r)
	w.WriteHeader(code)
	w.Write(res)
}
