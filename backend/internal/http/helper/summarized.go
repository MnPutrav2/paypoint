package helper

import (
	"context"
	errorhttp "kavi-kasir/internal/http/error"
	kategoriService "kavi-kasir/internal/service/kategori"
	"kavi-kasir/pkg/header"
	"kavi-kasir/pkg/middleware"
	"kavi-kasir/pkg/page"
	"kavi-kasir/pkg/response"
	"net/http"
)

func Summarized(ctx context.Context, serv kategoriService.KategoriService, handle func(ctx context.Context) (any, error)) http.HandlerFunc {
	return middleware.Authorization(func(w http.ResponseWriter, r *http.Request) {
		dx, ls, err := header.References(ctx, r, serv)
		if err != nil {
			message, code := errorhttp.Map(err)
			response.Message(message, err.Error(), "ERROR", code, w, r)
			return
		}

		result, err := handle(ctx)
		if err != nil {
			message, code := errorhttp.Map(err)
			response.Message(message, err.Error(), "ERROR", code, w, r)
			return
		}

		res := page.SummarizedResponse(result)
		res.Meta.Reference.Data = &dx
		res.Meta.Reference.Last = &ls
		response.JSONPaginated(res.Result, res.Meta, "success", "INFO", w, r)
	})
}
