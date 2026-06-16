package response

import (
	"encoding/json"
	"kavi-kasir/internal/model"
	logging "kavi-kasir/pkg/logging"
	"net/http"
)

func JSONPaginated(response any, meta any, log string, ty string, w http.ResponseWriter, r *http.Request) {
	var s bool

	switch ty {
	case "INFO":
		s = true
	case "WARN":
		s = false
	case "ERROR":
		s = false
	}

	res, _ := json.Marshal(model.ResponseBodyPaginated{Status: 200, Success: s, Result: response, Meta: meta})
	logging.Log(log, ty, r)
	w.WriteHeader(200)
	w.Write(res)
}
