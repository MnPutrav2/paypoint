package response

import (
	"encoding/json"
	"kavi-kasir/internal/model"
	logging "kavi-kasir/pkg/logging"
	"net/http"
)

func JSON(response any, log string, ty string, code int, w http.ResponseWriter, r *http.Request) {
	var s bool

	switch ty {
	case "INFO":
		s = true
	case "WARN":
		s = false
	case "ERROR":
		s = false
	}

	res, _ := json.Marshal(model.ResponseBody{Status: code, Success: s, Result: response})
	logging.Log(log, ty, r)
	w.WriteHeader(code)
	w.Write(res)
}

func JSON2(response any, reference model.ReferenceResult, log string, ty string, code int, w http.ResponseWriter, r *http.Request) {
	var s bool

	switch ty {
	case "INFO":
		s = true
	case "WARN":
		s = false
	case "ERROR":
		s = false
	}

	res, _ := json.Marshal(model.ResponseBody{Status: code, Success: s, Result: response, Reference: reference})
	logging.Log(log, ty, r)
	w.WriteHeader(code)
	w.Write(res)
}
