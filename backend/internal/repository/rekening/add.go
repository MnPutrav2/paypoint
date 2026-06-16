package rekeningRepo

import (
	"context"
	rekeningModel "kavi-kasir/internal/model/rekening"
)

func (q *rekeningRepository) AddRekening(ctx context.Context, req *rekeningModel.Rekening) (rekeningModel.Rekening, error) {
	var rekening rekeningModel.Rekening

	if err := q.db.WithContext(ctx).Create(&req).Error; err != nil {
		return rekeningModel.Rekening{}, err
	}

	if err := q.db.WithContext(ctx).Model(&rekeningModel.Rekening{}).Preload("Bank").Where("user_id = ? AND bank_id = ?", req.UserID, req.BankID).Find(&rekening).Error; err != nil {
		return rekeningModel.Rekening{}, err
	}

	return rekening, nil
}
