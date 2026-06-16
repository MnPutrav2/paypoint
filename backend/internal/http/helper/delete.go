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

func Delete(path string, w http.ResponseWriter, r *http.Request, handle func(uuid.UUID) error) {
	uid, message, err := util.GetParameter(r, path)
	if err != nil {
		response.Message(message, err.Error(), "ERROR", http.StatusBadRequest, w, r)
		return
	}

	if err := handle(uid); err != nil {
		return
	}

	response.Message("success", "success", "INFO", http.StatusOK, w, r)
}

func Delete2(ctx context.Context, path string, serv kategoriService.KategoriService, handle func(ctx context.Context, id, user uuid.UUID) error) http.HandlerFunc {
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

		userID := ctx.Value(utilConst.ContextUserID).(uuid.UUID)

		if err := handle(ctx, uid, userID); err != nil {
			message, code := errorhttp.Map(err)
			response.Message2(message, reference, err.Error(), "ERROR", code, w, r)
			return
		}

		response.Message2("success", reference, "success", "INFO", http.StatusOK, w, r)
	})
}

func Delete3(ctx context.Context, path string, w http.ResponseWriter, r *http.Request, serv kategoriService.KategoriService, c *jwtEnc.Claims, handle func(ctx context.Context, id, user uuid.UUID) error) {
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

	if err := handle(ctx, uid, c.UserID); err != nil {
		message, code := errorhttp.Map(err)
		response.Message2(message, reference, err.Error(), "ERROR", code, w, r)
		return
	}

	response.Message2("success", reference, "success", "INFO", http.StatusOK, w, r)
}
