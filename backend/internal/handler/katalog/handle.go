package katalogHandle

import (
	"context"
	"kavi-kasir/internal/http/helper"
	"kavi-kasir/internal/mapper"
	katalogModel "kavi-kasir/internal/model/katalog"
	katalogService "kavi-kasir/internal/service/katalog"
	kategoriService "kavi-kasir/internal/service/kategori"
	jwtEnc "kavi-kasir/pkg/auth/jwt"
	utilConst "kavi-kasir/pkg/util/const"
	"net/http"
	"time"

	"github.com/google/uuid"
)

// @Summary      Menampilkan data katalog
// @Description Menampilkan data katalog
// @Tags         katalog
// @Accept       json
// @Produce      json
// @Param        page path int false "page"
// @Param        size path int false "size"
// @Param        keyword path string false "keyword"
// @Success      200 {object} model.KatalogTest
// @Router       /katalog [get]
func Get(serv katalogService.KatalogService, rep kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		helper.Paginated3(ctx, w, r, rep, func(ctx context.Context, offsite, size int, keyword string,
			sortColumn string,
			sortDirection string) (any, int, error) {
			result, total, err := serv.GetAllKatalogPaginatedService(ctx, offsite, size, keyword)
			if err != nil {
				return nil, 0, err
			}

			data := mapper.MappingKatalogAll(result)
			return data, total, nil
		})
	}
}

// @Summary      Menambahkan katalog
// @Description Menambahkan katalog
// @Tags         katalog
// @Accept       json
// @Produce      json
// @Param        body body katalogModel.KatalogCreate true "Field order"
// @Success      200 {object} model.ResponseMessage
// @Router       /katalog [post]
func Create(serv katalogService.KatalogService, ser kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		c := ctx.Value(utilConst.ContextUserID).(*jwtEnc.Claims)
		helper.Post4(ctx, w, r, ser, func(ctx context.Context, data katalogModel.KatalogCreateRequest) (katalogModel.KatalogShow, error) {
			c := mapper.MappingKatalogCreate(data, c.UserID)
			result, err := serv.CreateKatalogService(ctx, &c)
			if err != nil {
				return katalogModel.KatalogShow{}, err
			}

			ma := mapper.MappingKatalog(result)
			return ma, nil
		})
	}
}

// @Summary      Ambil katalog berdasarkan id
// @Description ambil data katalog
// @Tags         katalog
// @Accept       json
// @Produce      json
// @Param        katalog_id path string true "katalog_id"
// @Success      200 {object} katalogModel.KatalogShow
// @Router       /katalog/{katalog_id} [get]
func GetByID(serv katalogService.KatalogService, ser kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		helper.Get3(ctx, "/katalog/", ser, w, r, func(ctx context.Context, id uuid.UUID) (katalogModel.KatalogShow, error) {
			result, err := serv.GetKatalogByIdService(ctx, id)
			if err != nil {
				return katalogModel.KatalogShow{}, err
			}

			res := mapper.MappingKatalog(result)
			return res, nil
		})

	}
}

// @Summary      Hapus katalog
// @Description Menghapus data katalog
// @Tags         katalog
// @Accept       json
// @Produce      json
// @Param        katalog_id path string true "katalog_id"
// @Success      200 {object} model.ResponseMessage
// @Router       /katalog/{katalog_id} [delete]
func Delete(serv katalogService.KatalogService, ser kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		c := ctx.Value(utilConst.ContextUserID).(*jwtEnc.Claims)
		helper.Delete3(ctx, "/katalog/", w, r, ser, c, func(ctx context.Context, id, user uuid.UUID) error {
			if err := serv.DeleteKatalogService(ctx, id, user); err != nil {
				return err
			}

			return nil
		})
	}
}

// @Summary      Ubah harga katalog
// @Description Mengubah harga katalog
// @Tags         katalog
// @Accept       json
// @Produce      json
// @Param        katalog_id path string true "katalog_id"
// @Param        body body katalogModel.UpdateKatalog true "Field katalog"
// @Success      200 {object} katalogModel.KatalogShow
// @Router       /katalog/{katalog_id} [patch]
func Patch(serv katalogService.KatalogService, ser kategoriService.KategoriService) http.HandlerFunc {

	return func(w http.ResponseWriter, r *http.Request) {
		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		c := ctx.Value(utilConst.ContextUserID).(*jwtEnc.Claims)

		helper.Update3(ctx, "/katalog/", w, r, ser, c, func(ctx context.Context, id, user uuid.UUID, body katalogModel.KatalogCreate) (katalogModel.KatalogShow, error) {
			dt, err := serv.UpdateKatalogService(ctx, id, user, body.Harga)
			if err != nil {
				return katalogModel.KatalogShow{}, err
			}

			res := mapper.MappingKatalog(dt)
			return res, nil
		})
	}
}
