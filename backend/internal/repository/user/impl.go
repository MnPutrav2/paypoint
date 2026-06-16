package userRepo

import (
	"context"
	"kavi-kasir/internal/model"
	userModel "kavi-kasir/internal/model/user"
	utilConst "kavi-kasir/pkg/util/const"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type userRepository struct {
	db *gorm.DB
}

type UserRepository interface {
	BeginTx(ctx context.Context) *gorm.DB
	GetUserAccount(payload userModel.Login) (userModel.User, error)
	GetUserById(ctx context.Context, id uuid.UUID) (userModel.User, error)
	GetUserListPagination(ctx context.Context, page, size int, keyword string) ([]userModel.User, int, error)
	GetUserDetail(ctx context.Context, id uuid.UUID) (userModel.User, error)
	CreateAccessToken(token *userModel.AccessToken) error
	// UpdateUser(ctx context.Context, id uuid.UUID, req *userModel.UserUpdate) (userModel.UserUpdate, error)
	UpdateSelectedUser(ctx context.Context, id uuid.UUID, req map[string]interface{}) (map[string]interface{}, userModel.User, error)
	UpdateImageUser(ctx context.Context, id uuid.UUID, img string) ([]model.UpdateKey, error)
	DeleteUser(ctx context.Context, id uuid.UUID) error
	GetSaldo(ctx context.Context, userID uuid.UUID) (int64, error)
	UpdateSaldo(ctx context.Context, userID uuid.UUID, saldo int64, tipe utilConst.UPDATE_SALDO_TYPE) error
}

func NewUserRepository(db *gorm.DB) UserRepository {
	return &userRepository{db: db}
}
