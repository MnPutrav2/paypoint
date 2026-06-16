package kategoriService

import (
	"context"
	kategoriModel "kavi-kasir/internal/model/kategori"

	"github.com/google/uuid"
)

func (s *kategoriService) GetById(ctx context.Context, id uuid.UUID) (kategoriModel.Kategori, error) {
	result, err := s.repo.GetById(ctx, id)
	if err != nil {
		return kategoriModel.Kategori{}, err
	}

	return result, nil
}
