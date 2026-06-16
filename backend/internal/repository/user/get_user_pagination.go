package userRepo

import (
	"context"
	userModel "kavi-kasir/internal/model/user"
)

func (q *userRepository) GetUserListPagination(ctx context.Context, page, size int, keyword string) ([]userModel.User, int, error) {
	var (
		user  []userModel.User
		total int64
	)
	db := q.db.WithContext(ctx).Model(&userModel.User{})

	if keyword != "" {
		db = db.Where("nama ILIKE ?", "%"+keyword+"%")
	}

	// Count
	if err := db.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	if err := db.
		Preload("Kategori").
		Preload("Kategori.RefKategori").
		Limit(size).
		Offset(page).
		Find(&user).Error; err != nil {
		return nil, 0, err
	}
	// if err := q.db.WithContext(ctx).Model(&userModel.User{}).Where("nama ILIKE ?", "%"+keyword+"%").Count(&total).Error; err != nil {
	// 	return nil, 0, err
	// }

	// if err := q.db.WithContext(ctx).Where("nama ILIKE ?", "%"+keyword+"%").Preload("Kategori").Preload("Kategori.RefKategori").Limit(size).Offset(page).Find(&user).Error; err != nil {
	// 	return nil, 0, err
	// }

	return user, int(total), nil
}
