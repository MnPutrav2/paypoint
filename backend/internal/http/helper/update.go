package helper

import (
	"context"
	errorhttp "kavi-kasir/internal/http/error"
	"kavi-kasir/internal/model"
	kategoriService "kavi-kasir/internal/service/kategori"
	jwtEnc "kavi-kasir/pkg/auth/jwt"
	"kavi-kasir/pkg/header"
	"kavi-kasir/pkg/middleware"
	"kavi-kasir/pkg/response"
	"kavi-kasir/pkg/util"
	utilConst "kavi-kasir/pkg/util/const"
	"net/http"

	"github.com/google/uuid"
)

func Update[T any](path string, w http.ResponseWriter, r *http.Request, handle func(uuid.UUID, T) (any, error)) {
	uid, message, err := util.GetParameter(r, path)
	if err != nil {
		response.Message(message, err.Error(), "WARN", 400, w, r)
		return
	}

	body, err := util.BodyDecoder[T](r)
	if err != nil {
		response.Message("failed decode data", err.Error(), "WARN", 400, w, r)
		return
	}

	result, err := handle(uid, body)
	if err != nil {
		return
	}

	response.JSON(result, "success", "INFO", http.StatusOK, w, r)
}

func Update2[T any, R any](ctx context.Context, path string, serv kategoriService.KategoriService, handle func(ctx context.Context, id, user uuid.UUID, body T) (R, error)) http.HandlerFunc {
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

		body, err := util.BodyDecoder[T](r)
		if err != nil {
			response.Message2("failed decode body", reference, err.Error(), "ERROR", 400, w, r)
			return
		}
		userID := ctx.Value(utilConst.ContextUserID).(uuid.UUID)

		result, err := handle(ctx, uid, userID, body)
		if err != nil {
			message, code := errorhttp.Map(err)
			response.Message2(message, reference, err.Error(), "ERROR", code, w, r)
			return
		}

		response.JSON2(result, reference, "success", "INFO", http.StatusOK, w, r)
	})
}

func Update3[T any, R any](ctx context.Context, path string, w http.ResponseWriter, r *http.Request, serv kategoriService.KategoriService, c *jwtEnc.Claims, handle func(ctx context.Context, id, user uuid.UUID, body T) (R, error)) {
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

	body, err := util.BodyDecoder[T](r)
	if err != nil {
		response.Message2("failed decode body", reference, err.Error(), "ERROR", 400, w, r)
		return
	}

	result, err := handle(ctx, uid, c.UserID, body)
	if err != nil {
		message, code := errorhttp.Map(err)
		response.Message2(message, reference, err.Error(), "ERROR", code, w, r)
		return
	}

	response.JSON2(result, reference, "success", "INFO", http.StatusOK, w, r)
}
