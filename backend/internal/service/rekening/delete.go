package rekeningService

import (
	"context"
	errorhttp "kavi-kasir/internal/http/error"

	"github.com/google/uuid"
)

func (s *rekeningService) DeleteService(ctx context.Context, id uuid.UUID, userId uuid.UUID) error {
	tx, err := s.repo.DeleteRekening(ctx, id, userId)
	if err != nil {
		return err
	}

	if tx == 0 {
		return errorhttp.ErrDeleteRek
	}

	return nil
}
