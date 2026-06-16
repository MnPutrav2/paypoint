package userRepo

import (
	"context"
	"kavi-kasir/internal/model"
	userModel "kavi-kasir/internal/model/user"
	"kavi-kasir/pkg/minio"
	"net/url"

	"github.com/google/uuid"
)

func (q *userRepository) UpdateImageUser(ctx context.Context, id uuid.UUID, img string) ([]model.UpdateKey, error) {
	if err := q.db.WithContext(ctx).Model(&userModel.User{}).Where("id = ?", id).Update("foto", img).Error; err != nil {
		return nil, err
	}

	var m []model.UpdateKey
	reqParams := make(url.Values)
	reqParams.Set("response-content-disposition", "inline")
	// presignedURL, _ := minio.NewMinio().PresignedGetObject(context.Background(), os.Getenv("MINIO_BUCKET"), img, time.Minute*10, reqParams)
	m = append(m, model.UpdateKey{
		Key: "foto",
		// Value: presignedURL.String(),
		Value: minio.GetPublicURL(img),
	})

	return m, nil
}
