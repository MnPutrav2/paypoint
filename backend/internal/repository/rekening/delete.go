package rekeningRepo

import (
	"context"
	rekeningModel "kavi-kasir/internal/model/rekening"

	"github.com/google/uuid"
)

func (q *rekeningRepository) DeleteRekening(ctx context.Context, id uuid.UUID, userId uuid.UUID) (int64, error) {
	tx := q.db.WithContext(ctx).Where("id = ? AND user_id = ? AND saldo <= 0", id, userId).Delete(&rekeningModel.Rekening{})

	return tx.RowsAffected, tx.Error
}
