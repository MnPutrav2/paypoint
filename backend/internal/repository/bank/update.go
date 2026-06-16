package bankRepo

import (
	"context"
	bankModel "kavi-kasir/internal/model/bank"

	"github.com/google/uuid"
)

func (q *bankRepository) UpdateBank(ctx context.Context, id uuid.UUID, req *bankModel.BankUpdate) (bankModel.BankUpdate, error) {
	if err := q.db.WithContext(ctx).Model(&bankModel.Bank{}).Where("id = ?", id).Error; err != nil {
		return bankModel.BankUpdate{}, err
	}

	return *req, nil
}
