package authRepo

import userModel "kavi-kasir/internal/model/user"

func (q *authRepositry) CreateUserAccount(user *userModel.User) (userModel.User, error) {
	var us userModel.User

	if err := q.db.Create(&user).Error; err != nil {
		return userModel.User{}, err
	}

	if err := q.db.Model(userModel.User{}).Preload("Kategori").Preload("Kategori.RefKategori").Where("id = ?", user.ID).Find(&us).Error; err != nil {
		return userModel.User{}, err
	}

	return us, nil
}
