package bankRepo

import (
	"context"
	bankModel "kavi-kasir/internal/model/bank"

	"github.com/google/uuid"
)

func (q *bankRepository) DeleteBank(ctx context.Context, id uuid.UUID) (int64, error) {
	tx := q.db.WithContext(ctx).Where("id = ?", id).Delete(&bankModel.Bank{})

	return tx.RowsAffected, tx.Error
}
