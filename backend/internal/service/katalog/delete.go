package katalogService

import (
	"context"

	"github.com/google/uuid"
)

func (s *katalogService) DeleteKatalogService(ctx context.Context, id, userId uuid.UUID) error {
	if err := s.repo.DeleteKatalog(ctx, id, userId); err != nil {
		return err
	}

	return nil
}
