package bankService

import (
	"context"
	bankModel "kavi-kasir/internal/model/bank"

	"github.com/google/uuid"
)

func (s *bankService) GetAllByIdService(ctx context.Context, id uuid.UUID) ([]bankModel.Bank, string, int, error) {
	result, err := s.repo.GetAllbyId(ctx, id)
	if err != nil {
		return nil, "failed get data", 400, err
	}

	return result, "success", 200, nil
}
