package authService

import (
	userModel "kavi-kasir/internal/model/user"
	"kavi-kasir/pkg/password"
)

func (s *authService) CreateAccountService(user *userModel.User) (userModel.User, error) {

	pass, err := password.HashPassword(user.Password)
	if err != nil {
		return userModel.User{}, err
	}

	user.Password = pass
	result, err := s.repo.CreateUserAccount(user)
	if err != nil {
		return userModel.User{}, err
	}

	return result, nil
}
