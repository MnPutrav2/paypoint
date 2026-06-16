package userRepo

import userModel "kavi-kasir/internal/model/user"

func (q *userRepository) CreateAccessToken(token *userModel.AccessToken) error {
	if err := q.db.Create(&token).Error; err != nil {
		return err
	}

	return nil
}
