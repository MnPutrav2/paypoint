package bankService

import (
	"context"
	bankModel "kavi-kasir/internal/model/bank"

	"github.com/google/uuid"
)

func (s *bankService) UpdateBankService(ctx context.Context, id uuid.UUID, req bankModel.BankUpdate) (bankModel.BankUpdate, error) {

	result, err := s.repo.UpdateBank(ctx, id, &req)
	if err != nil {
		return bankModel.BankUpdate{}, err
	}

	return result, nil
}
