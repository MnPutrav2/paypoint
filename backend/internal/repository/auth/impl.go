package authRepo

import (
	"context"
	authModel "kavi-kasir/internal/model/auth"
	userModel "kavi-kasir/internal/model/user"

	"gorm.io/gorm"
)

type authRepositry struct {
	db *gorm.DB
}

type AuthRepository interface {
	AuthLogin(ctx context.Context, token *authModel.AccessToken) error
	CheckUser(ctx context.Context, username string) (userModel.User, error)
	SaveToken(ctx context.Context, token *authModel.AccessToken, refresh *authModel.RefreshToken) error
	CreateUserAccount(user *userModel.User) (userModel.User, error)
}

func NewAuthRepository(db *gorm.DB) AuthRepository {
	return &authRepositry{db: db}
}
