package userService

import (
	"context"
	"kavi-kasir/internal/model"
	userModel "kavi-kasir/internal/model/user"
	userRepo "kavi-kasir/internal/repository/user"

	"github.com/google/uuid"
)

type userService struct {
	repo userRepo.UserRepository
}

type UserService interface {
	GetAllPaginated(ctx context.Context, page, size int, keyword string) ([]userModel.User, int, error)           // final
	GetDetailUser(ctx context.Context, id uuid.UUID) (userModel.User, error)                                      // final
	Login(user userModel.Login) (string, error)                                                                   // final                                                       // final
	UpdateSelected(ctx context.Context, id uuid.UUID, req map[string]any) (map[string]any, userModel.User, error) // final
	UpdateImage(ctx context.Context, id uuid.UUID, img string) ([]model.UpdateKey, error)                         // final
	DeleteUser(ctx context.Context, id uuid.UUID) error                                                           // final
}

func NewUserService(repo userRepo.UserRepository) UserService {
	return &userService{repo: repo}
}
