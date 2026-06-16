package produkService

import (
	"context"
	"kavi-kasir/internal/model"

	"github.com/google/uuid"
)

func (s *produkService) UpdateImage(ctx context.Context, id uuid.UUID, img string) ([]model.UpdateKey, string, error) {
	res, err := s.repo.UpdateImageProduk(ctx, id, img)
	if err != nil {
		return nil, "failed update image", err
	}

	return res, "success", nil
}
