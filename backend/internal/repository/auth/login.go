package authRepo

import (
	"context"
	authModel "kavi-kasir/internal/model/auth"
)

func (q *authRepositry) AuthLogin(ctx context.Context, token *authModel.AccessToken) error {

	if err := q.db.WithContext(ctx).Create(&token).Error; err != nil {
		return err
	}

	return nil
}
