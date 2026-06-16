package produkHandler

import (
	"context"
	"fmt"
	"kavi-kasir/internal/http/helper"
	"kavi-kasir/internal/mapper"
	"kavi-kasir/internal/model"
	"kavi-kasir/internal/model/entity"
	produkModel "kavi-kasir/internal/model/produk"
	kategoriService "kavi-kasir/internal/service/kategori"
	produkService "kavi-kasir/internal/service/produk"
	jwtEnc "kavi-kasir/pkg/auth/jwt"
	"kavi-kasir/pkg/form"
	"kavi-kasir/pkg/minio"
	"kavi-kasir/pkg/response"
	"kavi-kasir/pkg/util"
	utilConst "kavi-kasir/pkg/util/const"
	"net/http"
	"time"

	"github.com/google/uuid"
)

// @Summary      Ambil produk berdasarkan id
// @Description ambil data produk
// @Tags         produk
// @Accept       json
// @Produce      json
// @Param        produk_id path string true "produk_id"
// @Success      200 {object} produkModel.Produk
// @Router       /produk/{produk_id} [get]
func GetByID(serv produkService.ProdukService, ser kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		helper.Get3(ctx, "/produk/", ser, w, r, func(ctx context.Context, id uuid.UUID) (entity.ProdukWithKatalog, error) {
			result, err := serv.GetByID(ctx, id)
			if err != nil {
				return entity.ProdukWithKatalog{}, err
			}

			return result, nil
		})
	}
}

// @Summary      Ubah produk
// @Description Mengubah data produk
// @Tags         produk
// @Accept       json
// @Produce      json
// @Param        produk_id path string true "produk_id"
// @Param        body body produkModel.ProdukUpdate true "Field produk"
// @Success      200 {object} model.ResponseMessage
// @Router       /produk/{produk_id} [put]
func Put(serv produkService.ProdukService, ser kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		c := ctx.Value(utilConst.ContextUserID).(*jwtEnc.Claims)
		helper.Update3(ctx, "/produk/", w, r, ser, c, func(ctx context.Context, id, user uuid.UUID, body produkModel.ProdukUpdate) ([]model.UpdateKey, error) {
			result, err := serv.Update(ctx, id, body)
			if err != nil {
				return nil, err
			}

			res := mapper.MappingUpdateKeyStruct(result)
			return res, nil
		})
	}
}

// @Summary      Ubah produk
// @Description Mengubah salah satu kolom data produk
// @Tags         produk
// @Accept       json
// @Produce      json
// @Param        produk_id path string true "produk_id"
// @Param        body body produkModel.ProdukPatch true "Field produk"
// @Success      200 {object} model.ResponseMessage
// @Router       /produk/{produk_id} [patch]
func Patch(serv produkService.ProdukService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		uid, message, err := util.GetParameter(r, "/produk/")
		if err != nil {
			response.Message(message, err.Error(), "WARN", 400, w, r)
			return
		}

		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		file, header, err := r.FormFile("foto")
		if err != nil {
			body, err := util.BodyDecoder[produkModel.ProdukPatch](r)
			if err != nil {
				response.Message("failed decode body", err.Error(), "WARN", 500, w, r)
				return
			}

			ma := mapper.MappingPatchProduk(body)
			data, res, mess, err := serv.UpdateSelected(ctx, uid, ma)
			if err != nil {
				response.Message(mess, err.Error(), "WARN", 500, w, r)
				return
			}

			d := mapper.MappingUpdateKey(data, res)
			response.JSON(d, "success", "INFO", 200, w, r)
			return
		}

		key, err := minio.UploadFile(file, header.Size, header.Header.Get("Content-Type"))
		if err != nil {
			response.Message("failed upload file", err.Error(), "ERROR", 400, w, r)
			return
		}

		res, mess, err := serv.UpdateImage(ctx, uid, key)
		if err != nil {
			response.Message(mess, err.Error(), "WARN", 500, w, r)
			return
		}

		response.JSON(res, "success", "INFO", 200, w, r)
	}
}

// @Summary      Hapus produk
// @Description Menghapus data produk
// @Tags         produk
// @Accept       json
// @Produce      json
// @Param        produk_id path string true "produk_id"
// @Success      200 {object} model.ResponseMessage
// @Router       /produk/{produk_id} [delete]
func Delete(serv produkService.ProdukService, ser kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		c := ctx.Value(utilConst.ContextUserID).(*jwtEnc.Claims)
		helper.Delete3(ctx, "/produk/", w, r, ser, c, func(ctx context.Context, id, user uuid.UUID) error {
			if err := serv.Delete(ctx, id); err != nil {
				return err
			}

			return nil
		})
	}
}

// @Summary      Ambil produk
// @Description ambil data produk
// @Tags         produk
// @Accept       json
// @Produce      json
// @Param        page path int false "page"
// @Param        size path int false "size"
// @Param        keyword path string false "keyword"
// @Success      200 {object} model.PaginationResponseTest
// @Router       /produk [get]
// func get(serv produkService.ProdukService, ctx context.Context, rep kategoriService.KategoriService) http.HandlerFunc {
// 	return header.Reference(ctx, rep, func(w http.ResponseWriter, r *http.Request, ref []kategoriModel.Reference, tm string) {
// 		page, offsite, size, keyword := pages.PaginationParameter(r)
// 		result, total, message, err := serv.GetAllPaginated(ctx, offsite, size, keyword)
// 		if err != nil {
// 			response.Message(message, err.Error(), "ERROR", 400, w, r)
// 			return
// 		}

// 		ma := mapper.MappingSliceProdukSigned(result)
// 		res := pages.PaginationResponse(ma, page, size, total, keyword)
// 		res.Meta.Reference.Data = &ref
// 		res.Meta.Reference.Last = &tm
// 		response.JSONPaginated(res.Result, res.Meta, "success", "INFO", w, r)
// 	})
// }

func Get(serv produkService.ProdukService, rep kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		helper.Paginated3(ctx, w, r, rep, func(ctx context.Context, offsite, size int, keyword string,
			sortColumn string,
			sortDirection string) (any, int, error) {
			result, total, _, err := serv.GetAllPaginated(ctx, offsite, size, keyword)
			if err != nil {
				return nil, 0, err
			}

			ma := mapper.MappingSliceProdukSigned(result)
			return ma, total, nil
		})
	}
}

// func get(serv produkService.ProdukService) http.HandlerFunc {
// 	return header.Reference(func(w http.ResponseWriter, r *http.Request, head string) {
// 		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
// 		defer close()

// 		page, offsite, size, keyword := pages.PaginationParameter(r)
// 		result, total, message, err := serv.GetAllPaginated(ctx, offsite, size, keyword)
// 		if err != nil {
// 			response.Message(message, err.Error(), "ERROR", 400, w, r)
// 			return
// 		}

// 		ma := mapper.MappingSliceProdukSigned(result)
// 		res := pages.PaginationResponse(ma, page, size, total, keyword)
// 		response.JSONPaginated(res.Result, res.Meta, "success", "INFO", w, r)
// 	})
// }

// @Summary      Buat produk
// @Description Membuat data produk
// @Tags         produk
// @Accept       json
// @Produce      json
// @Param        body body produkModel.ProdukTest true "Field produk"
// @Success      200 {object} model.ResponseMessage
// @Router       /produk [post]
func Post(serv produkService.ProdukService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		val, err := form.IsEmptyForm(r, []any{"", "", 0, uuid.UUID{}}, []string{"nama", "detail", "harga", "kategori_id"})
		if err != nil {
			response.Message(err.Error(), err.Error(), "WARN", 400, w, r)
			return
		}

		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		file, header, err := r.FormFile("foto")
		if err != nil {
			fmt.Println(file, " --- ", header)
			response.Message(err.Error(), "failed get file", "ERROR", 400, w, r)
			return
		}

		key, err := minio.UploadFile(file, header.Size, header.Header.Get("Content-Type"))
		if err != nil {
			response.Message("failed upload file", err.Error(), "ERROR", 400, w, r)
			return
		}

		body := produkModel.Produk{
			Nama:       val[0].(string),
			Detail:     val[1].(string),
			Foto:       key,
			Harga:      val[2].(int),
			KategoriID: val[3].(uuid.UUID),
		}

		produk := mapper.MappingCreateProduk(body)
		data, message, err := serv.Create(ctx, produk)
		if err != nil {
			response.Message(message, err.Error(), "ERROR", 400, w, r)
			return
		}

		result := mapper.MappingSingleProduk(&data)
		response.JSON(result, "success", "INFO", 200, w, r)
	}
}
