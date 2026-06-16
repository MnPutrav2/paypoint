package userService

import (
	"context"
	"kavi-kasir/internal/model"

	"github.com/google/uuid"
)

func (s *userService) UpdateImage(ctx context.Context, id uuid.UUID, img string) ([]model.UpdateKey, error) {
	res, err := s.repo.UpdateImageUser(ctx, id, img)
	if err != nil {
		return nil, err
	}

	return res, nil
}
