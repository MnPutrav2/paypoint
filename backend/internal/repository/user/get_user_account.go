package userRepo

import (
	userModel "kavi-kasir/internal/model/user"
)

func (q *userRepository) GetUserAccount(payload userModel.Login) (userModel.User, error) {
	var (
		user userModel.User
	)

	if err := q.db.Model(&userModel.User{}).Where("username = ?", payload.Username).First(&user).Error; err != nil {
		return userModel.User{}, err
	}

	return user, nil
}
