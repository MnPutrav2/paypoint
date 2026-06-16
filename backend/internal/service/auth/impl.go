package authService

import (
	"context"
	authModel "kavi-kasir/internal/model/auth"
	userModel "kavi-kasir/internal/model/user"
	authRepo "kavi-kasir/internal/repository/auth"
)

type authService struct {
	repo authRepo.AuthRepository
}

type AuthService interface {
	AuthLoginService(ctx context.Context, payload authModel.LoginRequest) (authModel.ResponseToken, error) // final
	CreateAccountService(user *userModel.User) (userModel.User, error)
}

func NewAuthService(repo authRepo.AuthRepository) AuthService {
	return &authService{repo: repo}
}
