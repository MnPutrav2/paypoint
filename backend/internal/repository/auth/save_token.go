package authRepo

import (
	"context"
	authModel "kavi-kasir/internal/model/auth"
)

func (q *authRepositry) SaveToken(ctx context.Context, token *authModel.AccessToken, refresh *authModel.RefreshToken) error {
	if err := q.db.WithContext(ctx).Create(&token).Error; err != nil {
		return err
	}

	refresh.AccessTokenID = token.ID
	if err := q.db.WithContext(ctx).Create(&refresh).Error; err != nil {
		return err
	}

	return nil
}
