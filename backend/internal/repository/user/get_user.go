package userRepo

import (
	"context"
	userModel "kavi-kasir/internal/model/user"

	"github.com/google/uuid"
)

func (q *userRepository) GetUserDetail(ctx context.Context, id uuid.UUID) (userModel.User, error) {
	var userDetail userModel.User
	if err := q.db.WithContext(ctx).Model(&userModel.User{}).Preload("Kategori").Preload("Kategori.RefKategori").Where("id = ?", id).Find(&userDetail).Error; err != nil {
		return userModel.User{}, err
	}

	return userDetail, nil
}
