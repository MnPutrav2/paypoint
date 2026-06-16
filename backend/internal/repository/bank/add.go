package bankRepo

import (
	"context"
	bankModel "kavi-kasir/internal/model/bank"
)

func (q *bankRepository) AddBank(ctx context.Context, req *bankModel.Bank) (bankModel.Bank, error) {
	var bank bankModel.Bank

	if err := q.db.WithContext(ctx).Create(&req).Error; err != nil {
		return bankModel.Bank{}, err
	}

	if err := q.db.WithContext(ctx).Model(&bankModel.Bank{}).Preload("Bank").Where("bank_id = ?", req.ID).Find(&bank).Error; err != nil {
		return bankModel.Bank{}, err
	}

	return bank, nil
}
