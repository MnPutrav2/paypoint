package produkRepo

import (
	"context"
	"kavi-kasir/internal/model"
	produkModel "kavi-kasir/internal/model/produk"
	"kavi-kasir/pkg/minio"
	"net/url"

	"github.com/google/uuid"
)

func (q *produkRepository) UpdateImageProduk(ctx context.Context, id uuid.UUID, img string) ([]model.UpdateKey, error) {
	if err := q.db.WithContext(ctx).Model(&produkModel.Produk{}).Where("id = ?", id).Update("foto", img).Error; err != nil {
		return nil, err
	}

	var m []model.UpdateKey
	reqParams := make(url.Values)
	reqParams.Set("response-content-disposition", "inline")
	// presignedURL, _ := minio.NewMinio().PresignedGetObject(context.Background(), os.Getenv("MINIO_BUCKET"), img, time.Minute*10, reqParams)
	m = append(m, model.UpdateKey{
		Key:   "foto",
		Value: minio.GetPublicURL(img),
	})

	return m, nil
}
