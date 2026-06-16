package authRepo

import (
	"context"
	userModel "kavi-kasir/internal/model/user"
)

func (q *authRepositry) CheckUser(ctx context.Context, username string) (userModel.User, error) {
	var user userModel.User
	if err := q.db.WithContext(ctx).Model(&userModel.User{}).Preload("Kategori").Where("username = ?", username).Find(&user).Error; err != nil {
		return userModel.User{}, err
	}

	return user, nil
}
