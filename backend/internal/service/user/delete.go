package userService

import (
	"context"

	"github.com/google/uuid"
)

func (s *userService) DeleteUser(ctx context.Context, id uuid.UUID) error {
	if err := s.repo.DeleteUser(ctx, id); err != nil {
		return err
	}

	return nil
}
