package header

import (
	"context"
	errorhttp "kavi-kasir/internal/http/error"
	kategoriModel "kavi-kasir/internal/model/kategori"
	kategoriService "kavi-kasir/internal/service/kategori"
	"kavi-kasir/pkg/response"
	"net/http"
	"time"
)

func Reference(ctx context.Context, serv kategoriService.KategoriService, next func(w http.ResponseWriter, r *http.Request, data []kategoriModel.Reference, tm string)) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		head := r.Header.Get("reference-last")

		if head != "null" {
			if head == "" {
				data, last, err := serv.RefreshReferenceDataService(ctx, nil)
				if err != nil {
					response.Message("gagal mengambil data reference", err.Error(), "WARN", http.StatusBadRequest, w, r)
					return
				}

				next(w, r, data, last)
				return
			}

			parse, err := time.Parse("2006-01-02 15:04:05", head)
			if err != nil {
				response.Message("reference-last harus berformat waktu YYYY-MM-DD HH:MM:SS", err.Error(), "WARN", http.StatusBadRequest, w, r)
				return
			}

			data, last, err := serv.RefreshReferenceDataService(ctx, &parse)
			if err != nil {
				response.Message("gagal mengambil data reference", err.Error(), "WARN", http.StatusBadRequest, w, r)
				return
			}

			next(w, r, data, last)
			return
		}
		data, last, err := serv.RefreshReferenceDataService(ctx, nil)
		if err != nil {
			response.Message("gagal mengambil data reference", err.Error(), "WARN", http.StatusBadRequest, w, r)
			return
		}

		next(w, r, data, last)
	}
}

func References(ctx context.Context, r *http.Request, serv kategoriService.KategoriService) ([]kategoriModel.Reference, string, error) {
	head := r.Header.Get("reference-last")
	var (
		dx []kategoriModel.Reference
		ls string
	)

	if head != "null" {
		if head == "" {
			data, last, err := serv.RefreshReferenceDataAllService(ctx)
			if err != nil {
				return nil, "", errorhttp.ErrGetRefLast
			}

			dx = data
			ls = last
			return dx, ls, nil
		}

		parse, err := time.Parse("2006-01-02 15:04:05", head)
		if err != nil {
			return nil, "", errorhttp.ErrTimeRefLast
		}

		data, last, err := serv.RefreshReferenceDataService(ctx, &parse)
		if err != nil {
			return nil, "", errorhttp.ErrGetRefLast
		}
		ls = last
		// last = 20266-02-01 15:00:00
		// head = 20266-02-01 15:00:00
		parseLast, _ := time.Parse("2006-01-02 15:04:05", last)
		if !parseLast.Equal(parse) {
			dx = data
		}

	} else {
		data, last, err := serv.RefreshReferenceDataService(ctx, nil)
		if err != nil {
			return nil, "", errorhttp.ErrGetRefLast
		}

		dx = data
		ls = last
	}

	return dx, ls, nil
}
