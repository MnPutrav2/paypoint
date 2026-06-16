package rekeningHandle

import (
	"context"
	"kavi-kasir/internal/http/helper"
	"kavi-kasir/internal/mapper"
	rekeningModel "kavi-kasir/internal/model/rekening"
	kategoriService "kavi-kasir/internal/service/kategori"
	rekeningService "kavi-kasir/internal/service/rekening"
	jwtEnc "kavi-kasir/pkg/auth/jwt"
	utilConst "kavi-kasir/pkg/util/const"
	"net/http"
	"time"

	"github.com/google/uuid"
)

// @Summary      Tambah data rekening
// @Description Tambah data rekening
// @Tags         rekening
// @Accept       json
// @Produce      json
// @Param        body body rekeningModel.Rekening true "Field produk"
// @Success      200 {object} rekeningModel.Rekening
// @Router       /rekening [post]
func Post(serv rekeningService.RekeningService, ser kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		c := ctx.Value(utilConst.ContextUserID).(*jwtEnc.Claims)
		helper.Post4(ctx, w, r, ser, func(ctx context.Context, data rekeningModel.Rekening) (rekeningModel.RekeningShow, error) {
			data.UserID = c.UserID
			result, err := serv.AddRekeningService(ctx, &data)
			if err != nil {
				return rekeningModel.RekeningShow{}, err
			}

			return mapper.MappingRekening(result), nil
		})
	}
}

// @Summary      Ambil data rekening
// @Description Ambil data rekening
// @Tags         rekening
// @Accept       json
// @Produce      json
// @Param        page path int false "page"
// @Param        size path int false "size"
// @Param        keyword path string false "keyword"
// @Success      200 {object} model.PaginationResponseTest
// @Router       /rekening [get]
func Get(serv rekeningService.RekeningService, ser kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		helper.Paginated3(ctx, w, r, ser, func(ctx context.Context, offsite, size int, keyword string,
			sortColumn string,
			sortDirection string) (any, int, error) {
			result, total, err := serv.GetAllPaginationService(ctx, offsite, size, keyword)
			if err != nil {
				return nil, 0, err
			}

			return mapper.MappingRekeningAll(result), total, nil
		})
	}
}

// @Summary      Ambil data rekening berdasarkan user id
// @Description Ambil data rekening berdasarkan user id
// @Tags         rekening
// @Accept       json
// @Produce      json
// @Success      200 {object} []rekeningModel.RekeningShow
// @Router       /rekening/{user_id} [get]
func GetByID(serv rekeningService.RekeningService, ser kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		helper.Get3(ctx, "/rekening/", ser, w, r, func(ctx context.Context, id uuid.UUID) ([]rekeningModel.RekeningShow, error) {
			result, err := serv.GetAllByIdService(ctx, id)
			if err != nil {
				return nil, err
			}

			return mapper.MappingRekeningAll(result), nil
		})
	}
}

// @Summary      Hapus data rekening user
// @Description Hapus data rekening user
// @Tags         rekening
// @Accept       json
// @Produce      json
// @Success      200 {object} model.ResponseMessage
// @Router       /rekening/{rekening_id} [delete]
func Delete(serv rekeningService.RekeningService, ser kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		c := ctx.Value(utilConst.ContextUserID).(*jwtEnc.Claims)
		helper.Delete3(ctx, "/rekening/", w, r, ser, c, func(ctx context.Context, id, user uuid.UUID) error {
			if err := serv.DeleteService(ctx, id, user); err != nil {
				return err
			}

			return nil
		})
	}
}

// @Summary      Tambah/kurangi saldo
// @Description Tambah/kurangi saldo
// @Tags         rekening
// @Accept       json
// @Produce      json
// @Param        body body rekeningModel.RekeningSaldo true "Field rekening"
// @Success      200 {object} model.ResponseMessage
// @Router       /rekening/{rekening_id} [patch]
func Patch(serv rekeningService.RekeningService, ser kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		c := ctx.Value(utilConst.ContextUserID).(*jwtEnc.Claims)
		helper.Update3(ctx, "/rekening/", w, r, ser, c, func(ctx context.Context, id, user uuid.UUID, body rekeningModel.RekeningSaldo) (rekeningModel.RekeningShow, error) {
			result, err := serv.SaldoService(ctx, id, user, body)
			if err != nil {
				return rekeningModel.RekeningShow{}, err
			}

			return mapper.MappingRekening(result), nil
		})
	}
}
