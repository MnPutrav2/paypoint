package helper

import (
	errorhttp "kavi-kasir/internal/http/error"
	"kavi-kasir/internal/model"
	"kavi-kasir/pkg/response"
	utilConst "kavi-kasir/pkg/util/const"
	"net/http"

	"github.com/google/uuid"
)

func WithReference[T any](
	req Request,
	handle func(id uuid.UUID) (T, error),
) {
	ref, ok := req.R.Context().Value(utilConst.ReferenceKey).(model.ReferenceResult)
	if !ok {
		response.Message("reference not found", "reference not found", "ERROR", http.StatusInternalServerError, req.W, req.R)
		return
	}

	var uid uuid.UUID
	if idStr := req.R.PathValue("id"); idStr != "" {
		uid, _ = uuid.Parse(idStr)
	}

	result, err := handle(uid)
	if err != nil {
		message, code := errorhttp.Map(err)
		response.Message2(message, ref, err.Error(), "ERROR", code, req.W, req.R)
		return
	}

	response.JSON2(result, ref, "success", "INFO", http.StatusOK, req.W, req.R)
}
