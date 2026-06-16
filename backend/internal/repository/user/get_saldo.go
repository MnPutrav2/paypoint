package userRepo

import (
	"context"
	userModel "kavi-kasir/internal/model/user"

	"github.com/google/uuid"
)

func (r *userRepository) GetSaldo(ctx context.Context, userID uuid.UUID) (int64, error) {
	var saldo int64
	err := r.db.WithContext(ctx).
		Model(&userModel.User{}).
		Where("id = ?", userID).
		Select("saldo").
		Scan(&saldo).Error
	return saldo, err
}
