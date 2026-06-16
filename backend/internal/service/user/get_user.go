package userService

import (
	"context"
	userModel "kavi-kasir/internal/model/user"

	"github.com/google/uuid"
)

func (s *userService) GetDetailUser(ctx context.Context, id uuid.UUID) (userModel.User, error) {
	result, err := s.repo.GetUserDetail(ctx, id)
	if err != nil {
		return userModel.User{}, err
	}

	return result, nil
}
