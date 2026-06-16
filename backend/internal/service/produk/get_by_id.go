package produkService

import (
	"context"
	"kavi-kasir/internal/model/entity"
	"kavi-kasir/pkg/minio"

	"github.com/google/uuid"
)

func (s *produkService) GetByID(ctx context.Context, id uuid.UUID) (entity.ProdukWithKatalog, error) {
	result, err := s.repo.GetProdukByIDProduk(ctx, id)
	if err != nil {
		return entity.ProdukWithKatalog{}, err
	}

	// reqParams := make(url.Values)
	// reqParams.Set("response-content-disposition", "inline")
	// presinedUrl, _ := minio.NewMinio().PresignedGetObject(context.Background(), os.Getenv("MINIO_BUCKET"), result.Foto, time.Minute*10, reqParams)
	// result.Foto = presinedUrl.String()
	result.Foto = minio.GetPublicURL(result.Foto)

	return result, nil
}
