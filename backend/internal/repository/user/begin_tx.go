package userRepo

import (
	"context"

	"gorm.io/gorm"
)

func (r *userRepository) BeginTx(ctx context.Context) *gorm.DB {
	return r.db.WithContext(ctx).Begin()
}
