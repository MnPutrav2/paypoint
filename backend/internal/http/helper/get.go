package helper

import (
	"context"
	errorhttp "kavi-kasir/internal/http/error"
	"kavi-kasir/internal/model"
	kategoriService "kavi-kasir/internal/service/kategori"
	"kavi-kasir/pkg/header"
	"kavi-kasir/pkg/middleware"
	"kavi-kasir/pkg/response"
	"kavi-kasir/pkg/util"
	"net/http"

	"github.com/google/uuid"
)

func Get(w http.ResponseWriter, r *http.Request, path string, handle func(id uuid.UUID) (any, error)) {
	uid, message, err := util.GetParameter(r, path)
	if err != nil {
		response.Message(message, err.Error(), "WARN", 400, w, r)
		return
	}

	result, err := handle(uid)
	if err != nil {
		return
	}

	response.JSON(result, "success", "INFO", 200, w, r)
}

func Get2[T any](ctx context.Context, path string, serv kategoriService.KategoriService, handle func(ctx context.Context, id uuid.UUID) (T, error)) http.HandlerFunc {
	return middleware.Authorization(func(w http.ResponseWriter, r *http.Request) {
		dx, ls, err := header.References(ctx, r, serv)
		if err != nil {
			message, code := errorhttp.Map(err)
			response.Message(message, err.Error(), "ERROR", code, w, r)
			return
		}

		reference := model.ReferenceResult{
			Data: &dx,
			Last: &ls,
		}

		uid, _, err := util.GetParameter(r, path)
		if err != nil {
			message, code := errorhttp.Map(err)
			response.Message2(message, reference, err.Error(), "ERROR", code, w, r)
			return
		}

		result, err := handle(ctx, uid)
		if err != nil {
			message, code := errorhttp.Map(err)
			response.Message2(message, reference, err.Error(), "ERROR", code, w, r)
			return
		}

		response.JSON2(result, reference, "success", "INFO", 200, w, r)
	})
}

func Get3[T any](ctx context.Context, path string, serv kategoriService.KategoriService, w http.ResponseWriter, r *http.Request, handle func(ctx context.Context, id uuid.UUID) (T, error)) {
	dx, ls, err := header.References(ctx, r, serv)
	if err != nil {
		message, code := errorhttp.Map(err)
		response.Message(message, err.Error(), "ERROR", code, w, r)
		return
	}

	reference := model.ReferenceResult{
		Data: &dx,
		Last: &ls,
	}

	uid, _, err := util.GetParameter(r, path)
	if err != nil {
		message, code := errorhttp.Map(err)
		response.Message2(message, reference, err.Error(), "ERROR", code, w, r)
		return
	}

	result, err := handle(ctx, uid)
	if err != nil {
		message, code := errorhttp.Map(err)
		response.Message2(message, reference, err.Error(), "ERROR", code, w, r)
		return
	}

	response.JSON2(result, reference, "success", "INFO", 200, w, r)
}

func Get4[T any](ctx context.Context, path string, serv kategoriService.KategoriService, w http.ResponseWriter, r *http.Request, handle func(ctx context.Context, id string) (T, error)) {
	dx, ls, err := header.References(ctx, r, serv)
	if err != nil {
		message, code := errorhttp.Map(err)
		response.Message(message, err.Error(), "ERROR", code, w, r)
		return
	}

	reference := model.ReferenceResult{
		Data: &dx,
		Last: &ls,
	}

	uid, _, err := util.ParamStr(r, path)
	if err != nil {
		message, code := errorhttp.Map(err)
		response.Message2(message, reference, err.Error(), "ERROR", code, w, r)
		return
	}

	result, err := handle(ctx, uid)
	if err != nil {
		message, code := errorhttp.Map(err)
		response.Message2(message, reference, err.Error(), "ERROR", code, w, r)
		return
	}

	response.JSON2(result, reference, "success", "INFO", 200, w, r)
}
