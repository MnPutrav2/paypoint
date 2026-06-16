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
)

func Post[T any, R any](w http.ResponseWriter, r *http.Request, handle func(T) (R, string, error)) {
	requestBody, err := util.BodyDecoder[T](r)
	if err != nil {
		response.Message("failed decode body", err.Error(), "ERROR", http.StatusBadRequest, w, r)
		return
	}

	responseData, message, err := handle(requestBody)
	if err != nil {
		return
	}

	response.JSON(responseData, message, "INFO", http.StatusCreated, w, r)
}

func Post2[T any, R any](ctx context.Context, serv kategoriService.KategoriService, handle func(ctx context.Context, data T) (R, error)) http.HandlerFunc {
	return middleware.Authorization(func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()

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

		body, err := util.BodyDecoder[T](r)
		if err != nil {
			response.Message2("failed decode body", reference, err.Error(), "ERROR", 400, w, r)
			return
		}

		result, err := handle(ctx, body)
		if err != nil {
			message, code := errorhttp.Map(err)
			response.Message2(message, reference, err.Error(), "ERROR", code, w, r)
			return
		}

		response.JSON2(result, reference, "success", "INFO", 201, w, r)
	})
}

func Post3[T any, R any](ctx context.Context, serv kategoriService.KategoriService, handle func(ctx context.Context, data T) (R, error)) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
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

		body, err := util.BodyDecoder[T](r)
		if err != nil {
			response.Message2("failed decode body", reference, err.Error(), "ERROR", 400, w, r)
			return
		}

		result, err := handle(ctx, body)
		if err != nil {
			message, code := errorhttp.Map(err)
			response.Message2(message, reference, err.Error(), "ERROR", code, w, r)
			return
		}

		response.JSON2(result, reference, "success", "INFO", 201, w, r)
	}
}

func Post4[T any, R any](ctx context.Context, w http.ResponseWriter, r *http.Request, serv kategoriService.KategoriService, handle func(ctx context.Context, data T) (R, error)) {
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

	body, err := util.BodyDecoder[T](r)
	if err != nil {
		response.Message2("failed decode body", reference, err.Error(), "ERROR", 400, w, r)
		return
	}

	result, err := handle(ctx, body)
	if err != nil {
		message, code := errorhttp.Map(err)
		response.Message2(message, reference, err.Error(), "ERROR", code, w, r)
		return
	}

	response.JSON2(result, reference, "success", "INFO", 201, w, r)
}
