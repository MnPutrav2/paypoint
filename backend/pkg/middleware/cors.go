package middleware

import (
	"net/http"
	"os"
	"strings"
)

func cors(w http.ResponseWriter, r *http.Request) bool {

	origin := r.Header.Get("Origin")

	envOrigins := os.Getenv("ALLOW_ORIGIN")
	allowedOrigins := strings.Split(envOrigins, ",")

	allow := false
	for _, o := range allowedOrigins {
		if strings.TrimSpace(o) == origin {
			allow = true
			break
		}

	}
	// for _, o := range allowedOrigins {
	// 	o = strings.TrimSpace(o)
	// 	// Exact match
	// 	if o == origin {
	// 		allow = true
	// 		break
	// 	}
	// 	// Wildcard subdomain — jika value di .env diawali *
	// 	// contoh: *.namadomainkamu.com
	// 	if strings.HasPrefix(o, "*.") {
	// 		domain := o[2:] // hapus "*."
	// 		if strings.HasSuffix(origin, "."+domain) ||
	// 			origin == "https://"+domain {
	// 			allow = true
	// 			break
	// 		}
	// 	}
	// }

	if allow {
		w.Header().Set("Access-Control-Allow-Origin", origin)
	}

	w.Header().Set("X-Content-Type-Options", "nosniff")
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS, DELETE, PUT, PATCH")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

	if r.Method == http.MethodOptions {
		w.WriteHeader(http.StatusOK)
		return true
	}

	return false

}

func CORS(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if cors(w, r) {
			return
		}

		next(w, r)
	}
}

func CORSHandler(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if cors(w, r) {
			return
		}

		next.ServeHTTP(w, r)
	})
}
