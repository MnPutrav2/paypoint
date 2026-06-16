package middleware

import (
	"kavi-kasir/pkg/response"
	"net"
	"net/http"
	"strings"
	"sync"
	"time"

	"golang.org/x/time/rate"
)

var visitors = make(map[string]*rate.Limiter)
var mu sync.Mutex

func ClientIP(r *http.Request) string {
	// Cloudflare
	if cfIP := r.Header.Get("CF-Connecting-IP"); cfIP != "" {
		return cfIP
	}

	// Reverse proxy umum
	if xff := r.Header.Get("X-Forwarded-For"); xff != "" {
		parts := strings.Split(xff, ",")
		return strings.TrimSpace(parts[0])
	}

	// Fallback
	if realIP := r.Header.Get("X-Real-IP"); realIP != "" {
		return realIP
	}

	// Last resort
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		return r.RemoteAddr
	}

	if host == "::1" {
		host = "127.0.0.1"
	}

	return host
}

func CleanupVisitors() {
	for {
		time.Sleep(time.Minute * 5)
		mu.Lock()
		for ip, limiter := range visitors {
			if limiter.Allow() {
				delete(visitors, ip)
			}
		}
		mu.Unlock()
	}
}

func limiterKey(r *http.Request) string {
	ip := ClientIP(r) // atau r.RemoteAddr
	return ip + "|" + r.Method + "|" + r.URL.Path
}

func limiter(r *http.Request, rps, burst int) *rate.Limiter {
	limit := rate.Every(time.Second / time.Duration(rps))
	key := limiterKey(r)

	mu.Lock()
	defer mu.Unlock()

	lim, exists := visitors[key]
	if !exists {
		lim = rate.NewLimiter(limit, burst)
		visitors[key] = lim
	}

	return lim
}

func RateLimiter(sec, burst int, next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		limiter := limiter(r, sec, burst)

		if !limiter.Allow() {
			response.Message("Too many requests.", "The demand for resources has already reached its maximum", "WARN", 429, w, r)

			return
		}

		next(w, r)
	}
}
