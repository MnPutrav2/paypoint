package bankRepo

import (
	"context"
	bankModel "kavi-kasir/internal/model/bank"

	"github.com/google/uuid"
)

func (q *bankRepository) GetAllbyId(ctx context.Context, id uuid.UUID) ([]bankModel.Bank, error) {
	var bank []bankModel.Bank
	if err := q.db.WithContext(ctx).Model(&bankModel.Bank{}).Preload("Bank").Where("user_id = ?", id).Find(&bank).Error; err != nil {
		return nil, err
	}

	return bank, nil
}
