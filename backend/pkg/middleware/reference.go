package middleware

import (
	"context"
	errorhttp "kavi-kasir/internal/http/error"
	"kavi-kasir/internal/model"
	kategoriService "kavi-kasir/internal/service/kategori"
	"kavi-kasir/pkg/header"
	"kavi-kasir/pkg/response"
	utilConst "kavi-kasir/pkg/util/const"
	"net/http"
)

func ReferenceMiddleware(ser kategoriService.KategoriService) func(http.HandlerFunc) http.HandlerFunc {
	return func(next http.HandlerFunc) http.HandlerFunc {
		return func(w http.ResponseWriter, r *http.Request) {
			dx, ls, err := header.References(r.Context(), r, ser)
			if err != nil {
				message, code := errorhttp.Map(err)
				response.Message(message, err.Error(), "ERROR", code, w, r)
				return
			}

			ctx := context.WithValue(r.Context(), utilConst.ReferenceKey, model.ReferenceResult{
				Data: &dx,
				Last: &ls,
			})

			next(w, r.WithContext(ctx))
		}
	}
}
