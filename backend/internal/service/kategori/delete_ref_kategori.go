package kategoriService

import (
	"context"

	"github.com/google/uuid"
)

func (s *kategoriService) DeleteRefKategoriService(ctx context.Context, id uuid.UUID) (string, int, error) {
	if err := s.repo.DeleteRefKategori(ctx, id); err != nil {
		return "failed delete produk", 400, err
	}

	return "success", 200, nil
}
