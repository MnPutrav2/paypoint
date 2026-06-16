package userHandel

import (
	"context"
	errorhttp "kavi-kasir/internal/http/error"
	"kavi-kasir/internal/http/helper"
	"kavi-kasir/internal/mapper"
	userModel "kavi-kasir/internal/model/user"
	kategoriService "kavi-kasir/internal/service/kategori"
	userService "kavi-kasir/internal/service/user"
	"kavi-kasir/pkg/minio"
	"kavi-kasir/pkg/response"
	"kavi-kasir/pkg/util"
	"net/http"
	"time"

	"github.com/google/uuid"
)

var baseUrl = "/users/"

// @Summary      Menampilkan detail user
// @Description Menampilkan detail user
// @Tags         user
// @Accept       json
// @Produce      json
// @Param        user_id path string true "user_id"
// @Success      200 {object} userModel.UserShow
// @Router       /users/{user_id} [get]
func Get(serv userService.UserService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		helper.Get(w, r, baseUrl, func(id uuid.UUID) (any, error) {
			ctx, close := context.WithTimeout(r.Context(), time.Second*5)
			defer close()

			result, err := serv.GetDetailUser(ctx, id)
			if err != nil {
				message, code := errorhttp.Map(err)
				response.Message(message, err.Error(), "WARN", code, w, r)
				return nil, err
			}

			data := mapper.MappingSingleUsers(result)
			return data, nil
		})
	}
}

// @Summary      Update data user
// @Description Update data user
// @Tags         user
// @Accept       json
// @Produce      json
// @Param        user_id path string true "user_id"
// @Param        body body userModel.UserPatch true "Field user"
// @Success      200 {object} userModel.UserShow
// @Router       /produk/{user_id} [patch]
func Patch(serv userService.UserService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		uid, message, err := util.GetParameter(r, baseUrl)
		if err != nil {
			response.Message(message, err.Error(), "WARN", 400, w, r)
			return
		}

		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		file, header, err := r.FormFile("foto")
		if err != nil {
			body, err := util.BodyDecoder[userModel.UserPatch](r)
			if err != nil {
				response.Message("failed decode body", err.Error(), "WARN", 500, w, r)
				return
			}
			ma := mapper.MappingPatchUser(body)
			data, res, err := serv.UpdateSelected(ctx, uid, ma)
			if err != nil {
				message, code := errorhttp.Map(err)
				response.Message(message, err.Error(), "WARN", code, w, r)
				return
			}

			d := mapper.MappingUpdateKeyUser(data, res)
			response.JSON(d, "success", "INFO", 200, w, r)
			return
		}

		key, err := minio.UploadFile(file, header.Size, header.Header.Get("Content-Type"))
		if err != nil {
			response.Message("failed upload file", err.Error(), "ERROR", 400, w, r)
			return
		}

		res, err := serv.UpdateImage(ctx, uid, key)
		if err != nil {
			message, code := errorhttp.Map(err)
			response.Message(message, err.Error(), "WARN", code, w, r)
			return
		}

		response.JSON(res, "success", "INFO", 200, w, r)
	}
}

// @Summary      Menghapus data user
// @Description Menghapus user
// @Tags         user
// @Accept       json
// @Produce      json
// @Success      200 {object} model.ResponseMessage
// @Router       /users/{user_id} [delete]
func Delete(serv userService.UserService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		uid, message, err := util.GetParameter(r, baseUrl)
		if err != nil {
			response.Message(message, err.Error(), "WARN", 400, w, r)
			return
		}

		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		if err := serv.DeleteUser(ctx, uid); err != nil {
			message, code := errorhttp.Map(err)
			response.Message(message, err.Error(), "WARN", code, w, r)
			return
		}

		response.Message("success", "success", "INFO", 200, w, r)
	}
}

// @Summary      Ambil semua data user
// @Description Ambil semua data user
// @Tags         user
// @Accept       json
// @Produce      json
// @Param        page path int false "page"
// @Param        size path int false "size"
// @Param        keyword path string false "keyword"
// @Success      200 {object} model.PaginationResponseTest
// @Router       /users [get]
func GetAll(serv userService.UserService, rep kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		helper.Paginated2(rep, func(ctx context.Context, offsite, size int, keyword string) (any, int, error) {
			result, total, err := serv.GetAllPaginated(ctx, offsite, size, keyword)
			if err != nil {
				return nil, 0, err
			}

			data := mapper.MappingUsers(result)
			return data, total, nil
		})
	}
}
