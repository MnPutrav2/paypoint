package stokHandler

import (
	stokModel "kavi-kasir/internal/model/stok"
	stokService "kavi-kasir/internal/service/stok"
	"kavi-kasir/pkg/response"
	"kavi-kasir/pkg/util"
	"net/http"

	"github.com/google/uuid"
)

// @Summary      Tambah atau rubah stok produk
// @Description Mengubah atau menambah stok produk
// @Tags         stok
// @Accept       json
// @Produce      json
// @Param        produk_id path string true "produk_id"
// @Param        body body stokModel.StokAdd true "Field produk"
// @Success      200 {object} model.ResponseMessage
// @Router       /stok/{produk_id} [patch]
func Patch(serv stokService.StokService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		message, id, err := util.ParamStr(r, "/stok/")
		if err != nil {
			response.Message(message, err.Error(), "WARN", 400, w, r)
			return
		}

		uid, err := uuid.Parse(id)
		if err != nil {
			response.Message("invalid parameter", err.Error(), "WARN", 400, w, r)
			return
		}

		body, err := util.BodyDecoder[stokModel.StokAdd](r)
		if err != nil {
			response.Message("failed decode body", err.Error(), "WARN", 500, w, r)
			return
		}

		mess, err := serv.Update(uid, body)
		if err != nil {
			response.Message(mess, err.Error(), "WARN", 500, w, r)
			return
		}

		response.Message("success", "success", "INFO", 200, w, r)
	}
}
