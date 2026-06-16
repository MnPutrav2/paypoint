package bankService

import (
	"context"
	"errors"

	"github.com/google/uuid"
)

func (s *bankService) DeleteService(ctx context.Context, id uuid.UUID) (string, int, error) {
	tx, err := s.repo.DeleteBank(ctx, id)
	if err != nil {
		return "failed remove data", 400, err
	}

	if tx == 0 {
		return "gagal menghapus bank, saldo harus 0", 400, errors.New("gagal menghapus bank, saldo harus 0")
	}

	return "success", 200, nil
}
