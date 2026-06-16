package produkService

import (
	"context"

	"github.com/google/uuid"
)

func (s *produkService) Delete(ctx context.Context, id uuid.UUID) error {
	if err := s.repo.DeleteProduk(ctx, id); err != nil {
		return err
	}

	return nil
}
