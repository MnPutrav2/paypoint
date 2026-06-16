package middleware

import (
	"net/http"
)

type Middleware func(http.HandlerFunc) http.HandlerFunc

func Chain(next http.HandlerFunc, middleware ...Middleware) http.HandlerFunc {
	for _, handle := range middleware {
		next = handle(next)
	}

	return next
}
