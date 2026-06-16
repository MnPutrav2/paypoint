package userService

import (
	"context"
	userModel "kavi-kasir/internal/model/user"

	"github.com/google/uuid"
)

func (q *userService) UpdateSelected(ctx context.Context, id uuid.UUID, req map[string]any) (map[string]any, userModel.User, error) {
	data, result, err := q.repo.UpdateSelectedUser(ctx, id, req)
	if err != nil {
		return nil, userModel.User{}, err
	}

	return data, result, nil
}
