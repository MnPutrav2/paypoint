package rekeningRepo

import (
	"context"
	rekeningModel "kavi-kasir/internal/model/rekening"

	"github.com/google/uuid"
)

func (q *rekeningRepository) GetAllbyId(ctx context.Context, id uuid.UUID) ([]rekeningModel.Rekening, error) {
	var rekening []rekeningModel.Rekening
	if err := q.db.WithContext(ctx).Model(&rekeningModel.Rekening{}).Preload("Bank").Where("user_id = ?", id).Find(&rekening).Error; err != nil {
		return nil, err
	}

	return rekening, nil
}
