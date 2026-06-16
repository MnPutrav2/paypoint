package userService

import (
	"context"
	userModel "kavi-kasir/internal/model/user"
)

func (q *userService) GetAllPaginated(ctx context.Context, page, size int, keyword string) ([]userModel.User, int, error) {
	result, total, err := q.repo.GetUserListPagination(ctx, page, size, keyword)
	if err != nil {
		return nil, 0, err
	}

	return result, total, nil
}
