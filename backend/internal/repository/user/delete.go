package userRepo

import (
	"context"
	userModel "kavi-kasir/internal/model/user"

	"github.com/google/uuid"
)

func (q *userRepository) DeleteUser(ctx context.Context, id uuid.UUID) error {
	if err := q.db.WithContext(ctx).Model(&userModel.User{}).Where("id = ?", id).Update("is_deleted", true).Error; err != nil {
		return err
	}

	return nil
}
