package rekeningRepo

import (
	"context"
	rekeningModel "kavi-kasir/internal/model/rekening"
)

func (q *rekeningRepository) GetAllPagination(ctx context.Context, page, size int, keyword string) ([]rekeningModel.Rekening, int, error) {
	var (
		rekening []rekeningModel.Rekening
		total    int64
	)

	if err := q.db.WithContext(ctx).Model(&rekeningModel.Rekening{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}

	if err := q.db.WithContext(ctx).Model(&rekeningModel.Rekening{}).Preload("Bank").Limit(size).Offset(page).Find(&rekening).Error; err != nil {
		return nil, 0, err
	}

	return rekening, int(total), nil
}
