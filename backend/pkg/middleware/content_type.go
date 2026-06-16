package middleware

import (
	"fmt"
	"kavi-kasir/pkg/response"
	"net/http"
	"strings"
)

func ContentType(contentType string, next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ct := r.Header.Get("Content-Type")
		if !strings.HasPrefix(ct, contentType) {
			response.Message(fmt.Sprintf("invalid content type, must be %s", contentType), fmt.Sprintf("invalid content type, must be %s", contentType), "WARN", 400, w, r)
			return
		}

		next(w, r)
	}
}

func CTJson(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ContentType("application/json", func(w http.ResponseWriter, r *http.Request) {
			next(w, r)
		})
	}
}

func CTFormData(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ContentType("multipart/form-data", func(w http.ResponseWriter, r *http.Request) {
			next(w, r)
		})
	}
}
