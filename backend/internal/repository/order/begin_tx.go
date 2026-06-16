package orderRepo

import (
	"context"

	"gorm.io/gorm"
)

func (r *orderRepository) BeginTx(ctx context.Context) *gorm.DB {
	return r.db.WithContext(ctx).Begin()
}
