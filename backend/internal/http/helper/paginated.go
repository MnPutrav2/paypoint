package helper

import (
	"context"
	errorhttp "kavi-kasir/internal/http/error"
	kategoriService "kavi-kasir/internal/service/kategori"
	"kavi-kasir/pkg/header"
	"kavi-kasir/pkg/middleware"
	pages "kavi-kasir/pkg/page"
	"kavi-kasir/pkg/response"
	"net/http"
)

func Paginated(w http.ResponseWriter, r *http.Request, handle func(int, int, int, string) (any, int, error)) {
	page, size, offsite, keyword := pages.PaginationParameter(r)

	result, total, err := handle(page, size, offsite, keyword)
	if err != nil {
		return
	}

	responseData := pages.PaginationResponse(result, page, size, total, keyword)
	response.JSONPaginated(responseData.Result, responseData.Meta, "success", "INFO", w, r)
}

// func Paginated2(ctx context.Context, serv kategoriService.KategoriService, handle func(ctx context.Context, offsite, size int, keyword string) (any, int, error)) http.HandlerFunc {
// 	return middleware.Authorization(func(w http.ResponseWriter, c *jwtEnc.Claims, r *http.Request) {
// 		dx, ls, err := header.References(ctx, r, serv)
// 		if err != nil {
// 			message, code := errorhttp.Map(err)
// 			response.Message(message, err.Error(), "ERROR", code, w, r)
// 			return
// 		}

// 		// Pagination

// 		p, o, s, k := pages.PaginationParameter(r)

// 		result, total, err := handle(ctx, o, s, k)
// 		if err != nil {
// 			message, code := errorhttp.Map(err)
// 			response.Message(message, err.Error(), "ERROR", code, w, r)
// 			return
// 		}

// 		res := pages.PaginationResponse(result, p, s, total, k)
// 		res.Meta.Reference.Data = &dx
// 		res.Meta.Reference.Last = &ls
// 		response.JSONPaginated(res.Result, res.Meta, "success", "INFO", w, r)
// 	})
// }

func Paginated2(
	serv kategoriService.KategoriService,
	handle func(ctx context.Context, offsite, size int, keyword string) (any, int, error),
) http.HandlerFunc {

	return middleware.Authorization(func(w http.ResponseWriter, r *http.Request) {

		ctx := r.Context()

		dx, ls, err := header.References(ctx, r, serv)
		if err != nil {
			message, code := errorhttp.Map(err)
			response.Message(message, err.Error(), "ERROR", code, w, r)
			return
		}

		p, o, s, k := pages.PaginationParameter(r)

		result, total, err := handle(ctx, o, s, k)
		if err != nil {
			message, code := errorhttp.Map(err)
			response.Message(message, err.Error(), "ERROR", code, w, r)
			return
		}

		res := pages.PaginationResponse(result, p, s, total, k)
		res.Meta.Reference.Data = &dx
		res.Meta.Reference.Last = &ls

		response.JSONPaginated(res.Result, res.Meta, "success", "INFO", w, r)
	})
}

func Paginated3(ctx context.Context, w http.ResponseWriter, r *http.Request, serv kategoriService.KategoriService, handle func(ctx context.Context, offsite, size int, keyword string,
	sortColumn string,
	sortDirection string) (any, int, error)) {
	dx, ls, err := header.References(ctx, r, serv)
	if err != nil {
		message, code := errorhttp.Map(err)
		response.Message(message, err.Error(), "ERROR", code, w, r)
		return
	}

	// Pagination

	p, o, s, k := pages.PaginationParameter(r)

	sortColumn := r.URL.Query().Get("sort_column")
	sortDirection := r.URL.Query().Get("sort_direction")

	result, total, err := handle(ctx, o, s, k,
		sortColumn,
		sortDirection)
	if err != nil {
		message, code := errorhttp.Map(err)
		response.Message(message, err.Error(), "ERROR", code, w, r)
		return
	}

	res := pages.PaginationResponse(result, p, s, total, k)
	res.Meta.Reference.Data = &dx
	res.Meta.Reference.Last = &ls
	response.JSONPaginated(res.Result, res.Meta, "success", "INFO", w, r)
}
