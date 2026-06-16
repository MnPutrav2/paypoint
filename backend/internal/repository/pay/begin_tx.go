package payRepo

import (
	"context"

	"gorm.io/gorm"
)

func (r *payRepository) BeginTx(ctx context.Context) *gorm.DB {
	return r.db.WithContext(ctx).Begin()
}
