package kategoriService

import (
	"context"

	"github.com/google/uuid"
)

func (s *kategoriService) DeleteKategoriService(ctx context.Context, id uuid.UUID) (string, int, error) {
	if err := s.repo.DeleteKategori(ctx, id); err != nil {
		return "failed delete produk", 400, err
	}

	return "success", 200, nil
}
