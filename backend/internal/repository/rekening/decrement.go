package rekeningRepo

import (
	"context"
	rekeningModel "kavi-kasir/internal/model/rekening"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

func (r *rekeningRepository) DecrementSaldo(ctx context.Context, id uuid.UUID, userId uuid.UUID, saldo int) (rekeningModel.Rekening, int64, error) {
	var rekening rekeningModel.Rekening

	tx := r.db.WithContext(ctx).Model(&rekeningModel.Rekening{}).Where("id = ? AND user_id = ? AND saldo >= ?", id, userId, saldo).Update("saldo", gorm.Expr("saldo - ?", saldo))

	if err := r.db.WithContext(ctx).Model(&rekeningModel.Rekening{}).Preload("Bank").Where("id = ? AND user_id = ?", id, userId).Find(&rekening).Error; err != nil {
		return rekeningModel.Rekening{}, 0, err
	}

	return rekening, tx.RowsAffected, tx.Error
}
