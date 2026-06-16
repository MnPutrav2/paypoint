package kategoriHandle

import (
	"context"
	"kavi-kasir/internal/http/helper"
	"kavi-kasir/internal/mapper"
	kategoriModel "kavi-kasir/internal/model/kategori"
	kategoriService "kavi-kasir/internal/service/kategori"
	"kavi-kasir/pkg/response"
	"net/http"
	"time"

	"github.com/google/uuid"
)

// @Summary      Buat kategori
// @Description Membuat kategori
// @Tags         kategori
// @Accept       json
// @Produce      json
// @Param        body body kategoriModel.KategoriCreate true "Field produk"
// @Success      200 {object} model.ResponseMessage
// @Router       /kategori [post]
func Post(serv kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		helper.Post(w, r, func(t kategoriModel.KategoriCreate) (kategoriModel.Kategori, string, error) {
			ctx, close := context.WithTimeout(r.Context(), time.Second*5)
			defer close()

			req := mapper.MapperCreateKategori(t)
			result, message, code, err := serv.CreateKategoriService(ctx, &req)
			if err != nil {
				response.Message(message, err.Error(), "WARN", code, w, r)
				return kategoriModel.Kategori{}, "", err
			}

			return result, message, nil
		})
	}
}

// @Summary      Buat referensi kategori
// @Description Membuat referensi kategori
// @Tags         referensi kategori
// @Accept       json
// @Produce      json
// @Param        body body kategoriModel.RefKategoriCreate true "Field produk"
// @Success      200 {object} model.ResponseMessage
// @Router       /ref-kategori [post]
func PostRef(serv kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		helper.Post(w, r, func(t kategoriModel.RefKategoriCreate) (kategoriModel.RefKategori, string, error) {
			ctx, close := context.WithTimeout(r.Context(), time.Second*5)
			defer close()

			req := mapper.MapperCreateRefKategori(t)
			result, message, code, err := serv.CreateRefKategoriService(ctx, &req)
			if err != nil {
				response.Message(message, err.Error(), "WARN", code, w, r)
				return kategoriModel.RefKategori{}, "", err
			}

			return result, message, nil
		})
	}
}

// @Summary      Menampilkan kategori
// @Description Menampilkan kategori
// @Tags         kategori
// @Accept       json
// @Produce      json
// @Param        page path int false "page"
// @Param        size path int false "size"
// @Param        keyword path string false "keyword"
// @Success      200 {object} model.PaginationKategoriTest
// @Router       /kategori [get]
func Get(serv kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, cancel := context.WithTimeout(r.Context(), time.Second*5)
		defer cancel()

		ref := r.URL.Query().Get("ref")

		helper.Paginated3(ctx, w, r, serv, func(ctx context.Context, offsite, size int, s string,
			sortColumn string,
			sortDirection string) (any, int, error) {
			result, total, message, code, err := serv.GetAllKategoriPaginated(ctx, offsite, size, s, ref)
			if err != nil {
				response.Message(message, err.Error(), "ERROR", code, w, r)
				return nil, 0, err
			}

			return mapper.MapperKategoriShowPagination(result), total, nil
		})
	}
}

// @Summary      Menampilkan data referensi kategori
// @Description Menampilkan data referensi kategori
// @Tags         referensi kategori
// @Accept       json
// @Produce      json
// @Param        page path int false "page"
// @Param        size path int false "size"
// @Param        keyword path string false "keyword"
// @Success      200 {object} model.PaginationRefKategoriTest
// @Router       /ref-kategori [get]
func GetRef(serv kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		helper.Paginated(w, r, func(i1, i2, i3 int, s string) (any, int, error) {
			ctx, cancel := context.WithTimeout(r.Context(), time.Second*5)
			defer cancel()

			result, total, message, code, err := serv.GetAllRefKategoriPaginated(ctx, i3, i2, s)
			if err != nil {
				response.Message(message, err.Error(), "ERROR", code, w, r)
				return nil, 0, err
			}

			return result, total, nil
		})
	}
}

// @Summary      Menampilkan semua data referensi kategori dan kategori
// @Description Menampilkan semua data referensi kategori dan kategori
// @Tags         refresh reference
// @Accept       json
// @Produce      json
// @Success      200 {object} kategoriModel.Reference
// @Router       /refresh/reference [get]
func Refresh(serv kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		body, message, code, err := serv.RefreshReferenceService(ctx)
		if err != nil {
			response.Message(message, err.Error(), "WARN", code, w, r)
			return
		}

		response.JSON(body, "success", "INFO", http.StatusOK, w, r)
	}
}

// @Summary      Hapus kategori
// @Description Menghapus data kategori
// @Tags         kategori
// @Accept       json
// @Produce      json
// @Param        kategori_id path string true "kategori_id"
// @Success      200 {object} model.ResponseMessage
// @Router       /kategori/{kategori_id} [delete]
func Delete(serv kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		helper.Delete("/kategori/", w, r, func(s uuid.UUID) error {
			ctx, cancel := context.WithTimeout(r.Context(), time.Second*5)
			defer cancel()

			message, code, err := serv.DeleteKategoriService(ctx, s)
			if err != nil {
				response.Message(message, err.Error(), "WARN", code, w, r)
				return err
			}

			return nil
		})
	}
}

// @Summary      Ubah kategori
// @Description Ubah data kategori
// @Tags         kategori
// @Accept       json
// @Produce      json
// @Param        kategori_id path string true "kategori_id"
// @Param        body body kategoriModel.KategoriCreate true "Field kategori"
// @Success      200 {object} model.ResponseMessage
// @Router       /kategori/{ref_kategori_id} [put]
func Update(serv kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		helper.Update("/kategori/", w, r, func(uid uuid.UUID, body kategoriModel.KategoriCreate) (any, error) {
			ctx, close := context.WithTimeout(r.Context(), time.Second*5)
			defer close()

			result, mess, code, err := serv.UpdateKategoriService(ctx, uid, body)
			if err != nil {
				response.Message(mess, err.Error(), "WARN", code, w, r)
				return nil, err
			}

			return mapper.MapperKategoriShow(result), nil
		})
	}
}

// @Summary      Ubah referensi kategori
// @Description Ubah data referensi kategori
// @Tags         referensi kategori
// @Accept       json
// @Produce      json
// @Param        ref_kategori_id path string true "ref_kategori_id"
// @Param        body body kategoriModel.RefKategoriCreate true "Field kategori"
// @Success      200 {object} model.ResponseMessage
// @Router       /ref-kategori/{ref_kategori_id} [put]
func UpdateRef(serv kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		helper.Update("/ref-kategori/", w, r, func(uid uuid.UUID, body kategoriModel.RefKategoriCreate) (any, error) {
			ctx, close := context.WithTimeout(r.Context(), time.Second*5)
			defer close()

			data, mess, code, err := serv.UpdateRefKategoriService(ctx, uid, body)
			if err != nil {
				response.Message(mess, err.Error(), "WARN", code, w, r)
				return nil, err
			}

			return mapper.MappingRefKategoriUpdateKey(data, uid), nil
		})
	}
}

// @Summary      Hapus referensi kategori
// @Description Menghapus data referensi kategori
// @Tags         referensi kategori
// @Accept       json
// @Produce      json
// @Param        ref_kategori_id path string true "ref_kategori_id"
// @Success      200 {object} model.ResponseMessage
// @Router       /ref-kategori/{ref_kategori_id} [delete]
func DeleteRef(serv kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		helper.Delete("/ref-kategori/", w, r, func(s uuid.UUID) error {
			ctx, cancel := context.WithTimeout(r.Context(), time.Second*5)
			defer cancel()

			message, code, err := serv.DeleteRefKategoriService(ctx, s)
			if err != nil {
				response.Message(message, err.Error(), "WARN", code, w, r)
				return err
			}

			return nil
		})
	}
}
