package bankHandle

import (
	"context"
	"kavi-kasir/internal/http/helper"
	"kavi-kasir/internal/mapper"
	bankModel "kavi-kasir/internal/model/bank"
	bankService "kavi-kasir/internal/service/bank"
	"kavi-kasir/pkg/response"
	"net/http"
	"time"

	"github.com/google/uuid"
)

// @Summary      Tambah data bank
// @Description Tambah data bank
// @Tags         bank
// @Accept       json
// @Produce      json
// @Param        body body bankModel.Bank true "Field produk"
// @Success      200 {object} bankModel.Bank
// @Router       /bank [post]
func Post(serv bankService.BankService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		helper.Post(w, r, func(body bankModel.Bank) (bankModel.BankShow, string, error) {
			ctx, close := context.WithTimeout(r.Context(), time.Second*5)
			defer close()

			result, message, code, err := serv.AddBankService(ctx, &body)
			if err != nil {
				response.Message(message, err.Error(), "ERROR", code, w, r)
				return bankModel.BankShow{}, message, err
			}

			return mapper.MappingBank(result), message, nil
		})
	}
}

// @Summary      Ambil data bank
// @Description Ambil data bank
// @Tags         bank
// @Accept       json
// @Produce      json
// @Param        page path int false "page"
// @Param        size path int false "size"
// @Param        keyword path string false "keyword"
// @Success      200 {object} model.PaginationResponseTest
// @Router       /bank [get]

func Get(serv bankService.BankService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		helper.Paginated(w, r, func(i1, i2, i3 int, s string) (any, int, error) {
			ctx, close := context.WithTimeout(r.Context(), time.Second*5)
			defer close()

			result, total, message, code, err := serv.GetAllPaginationService(ctx, i2, i3, s)
			if err != nil {
				response.Message(message, err.Error(), "ERROR", code, w, r)
				return nil, 0, err
			}

			return mapper.MappingBankAll(result), total, nil
		})
	}
}

// @Summary      Ambil data bank berdasarkan user id
// @Description Ambil data bank berdasarkan user id
// @Tags         bank
// @Accept       json
// @Produce      json
// @Success      200 {object} []bankModel.BankShow
// @Router       /bank/{user_id} [get]
func GetByID(serv bankService.BankService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		helper.Get(w, r, "/bank/", func(id uuid.UUID) (any, error) {
			ctx, close := context.WithTimeout(r.Context(), time.Second*5)
			defer close()

			result, message, code, err := serv.GetAllByIdService(ctx, id)
			if err != nil {
				response.Message(message, err.Error(), "WARN", code, w, r)
				return nil, err
			}

			data := mapper.MappingBankAll(result)
			return data, nil
		})
	}
}

// @Summary      Hapus data bank user
// @Description Hapus data bank user
// @Tags         bank
// @Accept       json
// @Produce      json
// @Success      200 {object} model.ResponseMessage
// @Router       /bank/{bank_id} [delete]
func Delete(serv bankService.BankService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		helper.Delete("/bank/", w, r, func(u uuid.UUID) error {
			ctx, close := context.WithTimeout(r.Context(), time.Second*5)
			defer close()

			// Need user id
			// Get user id by authorization

			message, code, err := serv.DeleteService(ctx, u)
			if err != nil {
				response.Message(message, err.Error(), "WARN", code, w, r)
				return err
			}

			return nil
		})
	}
}

// @Summary      Ubah bank
// @Description Mengubah data bank
// @Tags         bank
// @Accept       json
// @Produce      json
// @Param        bank_id path string true "bank_id"
// @Param        body body bankModel.BankUpdate true "Field bank"
// @Success      200 {object} model.ResponseMessage
// @Router       /bank/{bank_id} [put]
func Put(serv bankService.BankService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		helper.Update(
			"/bank/",
			w, r,
			func(id uuid.UUID, body bankModel.BankUpdate) (any, error) {
				result, err := serv.UpdateBankService(r.Context(), id, body)
				if err != nil {
					return nil, err
				}

				return mapper.MappingBankUpdate(result), nil
			},
		)
	}
}
