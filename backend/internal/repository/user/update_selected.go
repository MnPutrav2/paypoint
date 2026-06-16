package userRepo

import (
	"context"
	"errors"
	userModel "kavi-kasir/internal/model/user"

	"github.com/google/uuid"
)

func (q *userRepository) UpdateSelectedUser(ctx context.Context, id uuid.UUID, req map[string]any) (map[string]any, userModel.User, error) {

	// result := q.db.WithContext(ctx).Model(&userModel.User{}).Where("id = ? AND is_deleted = false", id).Updates(req)
	result := q.db.WithContext(ctx).Model(&userModel.User{}).Where("id = ?", id).Updates(req)
	var user userModel.User

	if result.Error != nil {
		return nil, userModel.User{}, result.Error
	}

	if result.RowsAffected == 0 {
		return nil, userModel.User{}, errors.New("user tidak ditemukan")
	}

	if err := q.db.WithContext(ctx).Model(&userModel.User{}).Preload("Kategori").Preload("Kategori.RefKategori").Where("id = ?", id).Find(&user).Error; err != nil {
		return nil, userModel.User{}, err
	}

	return req, user, nil
}
