package ip

import (
	"net"
	"net/http"
)

func ClientIP(r *http.Request) string {
	realIP := r.Header.Get("X-Real-IP")
	if realIP != "" {
		return realIP
	}

	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		return ""
	}

	if host == "::1" {
		host = "127.0.0.1"
	}

	return host
}
