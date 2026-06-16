package helper

import (
	"context"
	"net/http"
	"time"
)

type Request struct {
	W http.ResponseWriter
	R *http.Request
}

func NewRequest(w http.ResponseWriter, r *http.Request, timeout ...time.Duration) (Request, context.CancelFunc) {
	d := 5 * time.Second
	if len(timeout) > 0 {
		d = timeout[0]
	}
	ctx, cancel := context.WithTimeout(r.Context(), d)
	return Request{W: w, R: r.WithContext(ctx)}, cancel
}
