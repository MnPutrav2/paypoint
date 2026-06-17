package authHandle

import (
	"context"
	errorhttp "kavi-kasir/internal/http/error"
	"kavi-kasir/internal/mapper"
	authModel "kavi-kasir/internal/model/auth"
	authService "kavi-kasir/internal/service/auth"
	"kavi-kasir/pkg/enc"
	"kavi-kasir/pkg/form"
	"kavi-kasir/pkg/minio"
	"kavi-kasir/pkg/response"
	"kavi-kasir/pkg/util"
	"net/http"
	"time"
)

// @Summary      Login
// @Description Login
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        body body authModel.LoginRequest true "Field login"
// @Success      200 {object} authModel.ResponseToken
// @Router       /auth/login [post]
func Login(serv authService.AuthService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		payload, err := util.BodyDecoder[authModel.Payload](r)
		if err != nil {
			response.Message("server error", err.Error(), "ERROR", 400, w, r)
			return
		}

		body, err := enc.DecryptResponse[authModel.LoginRequest](payload.Payload)
		if err != nil {
			response.Message("server error", err.Error(), "ERROR", 400, w, r)
			return
		}

		ctx, cancel := context.WithTimeout(r.Context(), time.Second*5)
		defer cancel()

		result, err := serv.AuthLoginService(ctx, body)
		if err != nil {
			message, code := errorhttp.Map(err)
			response.Message(message, err.Error(), "WARN", code, w, r)
			return
		}

		response.JSON(result, "sukses", "INFO", 200, w, r)
	}
}

// @Summary      Membuat akun
// @Description Membuat akun
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        body body userModel.UserCreate true "Field order"
// @Success      200 {object} model.ResponseMessage
// @Router       /auth/register [post]
func Register(serv authService.AuthService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		val, err := form.IsEmptyForm(r, []any{"", "", "", "", ""}, []string{"username", "password", "nama", "email", "nomor_telepon"})
		if err != nil {
			response.Message(err.Error(), err.Error(), "WARN", 400, w, r)
			return
		}

		file, header, err := r.FormFile("foto")
		if err != nil {
			body := mapper.MappingUserCreate(val, "-")
			result, err := serv.CreateAccountService(&body)
			if err != nil {
				message, code := errorhttp.Map(err)
				response.Message(message, err.Error(), "WARN", code, w, r)
				return
			}

			ma := mapper.MappingSingleUsers(result)
			response.JSON(ma, "success", "INFO", 201, w, r)
			return
		}

		key, err := minio.UploadFile(file, header.Size, header.Header.Get("Content-Type"))
		if err != nil {
			response.Message("failed upload file", err.Error(), "ERROR", 400, w, r)
			return
		}

		body := mapper.MappingUserCreate(val, key)
		result, err := serv.CreateAccountService(&body)
		if err != nil {
			message, code := errorhttp.Map(err)
			response.Message(message, err.Error(), "WARN", code, w, r)
			return
		}

		ma := mapper.MappingSingleUsers(result)
		response.JSON(ma, "success", "INFO", 201, w, r)
	}
}
