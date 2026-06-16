package mapper

import (
	"fmt"
	"kavi-kasir/internal/model"
	userModel "kavi-kasir/internal/model/user"
	"kavi-kasir/pkg/minio"
	"net/url"
	"time"

	"github.com/google/uuid"
)

func MappingUserCreate(val []any, key string) userModel.User {
	return userModel.User{
		Username:   val[0].(string),
		Password:   val[1].(string),
		Nama:       val[2].(string),
		Foto:       key,
		Email:      val[3].(string),
		NoTelp:     val[4].(string),
		KategoriID: val[5].(uuid.UUID),
	}
}

func MappingPatchUser(req userModel.UserPatch) map[string]any {
	data := map[string]any{}

	if req.Nama != nil {
		data["nama"] = *req.Nama
	}
	if req.Username != nil {
		data["username"] = *req.Username
	}
	if req.Password != nil {
		data["password"] = *req.Password
	}
	if req.Email != nil {
		data["email"] = *req.Email
	}
	if req.NoTelp != nil {
		data["no_telp"] = *req.NoTelp
	}
	if req.Foto != nil {
		data["foto"] = *req.Foto
	}
	if req.KategoriID != nil {
		data["kategoriID"] = *req.KategoriID
	}

	return data
}

func MappingTokenCreate(userId uuid.UUID, token string, exp time.Time) userModel.AccessToken {
	return userModel.AccessToken{
		UserID:      userId,
		AccessToken: token,
		ExpiredAt:   exp,
	}
}

func MappingUsers(req []userModel.User) []userModel.UserShow {
	fmt.Println(req)
	ma := make([]userModel.UserShow, 0, len(req))
	m := minio.NewMinio()
	if m == nil {
		fmt.Println("MINIO NIL")
		return ma
	}

	reqParams := make(url.Values)
	reqParams.Set("response-content-disposition", "inline")

	// bucket := os.Getenv("MINIO_BUCKET")

	for _, v := range req {
		fotoURL := ""

		// if v.Foto != "" {
		// 	presignedURL, err := m.PresignedGetObject(
		// 		context.Background(),
		// 		bucket,
		// 		v.Foto,
		// 		time.Minute*10,
		// 		reqParams,
		// 	)
		// 	if err == nil {
		// 		fotoURL = presignedURL.String()
		// 	} else {
		// 		fmt.Println("Presign error:", err)
		// 	}
		// }

		ma = append(ma, userModel.UserShow{
			ID:       v.ID,
			Username: v.Username,
			Nama:     v.Nama,
			Email:    v.Email,
			NoTelp:   v.NoTelp,
			Foto:     fotoURL,
			Role:     v.Kategori.Nama,
		})
	}
	return ma
}

func MappingSingleUsers(v userModel.User) userModel.UserShow {
	reqParams := make(url.Values)
	reqParams.Set("response-content-disposition", "inline")

	// presignedURL, _ := minio.NewMinio().PresignedGetObject(context.Background(), os.Getenv("MINIO_BUCKET"), v.Foto, time.Minute*10, reqParams)
	return userModel.UserShow{
		ID:       v.ID,
		Username: v.Username,
		Nama:     v.Nama,
		Email:    v.Email,
		NoTelp:   v.NoTelp,
		Foto:     minio.GetPublicURL(v.Foto),
		Role:     v.Kategori.Nama,
	}
}

func MappingUpdateKeyUser(req map[string]any, res userModel.User) []model.UpdateKey {
	ma := make([]model.UpdateKey, 0, len(req))
	for key, value := range req {
		switch key {
		case "role":
			ma = append(ma, model.UpdateKey{
				Key:   "role",
				Value: res.Kategori.Nama, // ✅ STRING
			})
		case "kategoriID":
			ma = append(ma, model.UpdateKey{
				Key:   "role",
				Value: res.Kategori.Nama, // ✅ STRING
			})
		default:
			ma = append(ma, model.UpdateKey{
				Key:   key,
				Value: value,
			})
		}
	}

	return ma
}
