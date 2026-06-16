package orderService

import (
	"context"

	"github.com/google/uuid"
)

func (s *orderService) Delete(ctx context.Context, id uuid.UUID) error {
	if err := s.repo.DeleteOrder(ctx, id); err != nil {
		return err
	}

	return nil
}
