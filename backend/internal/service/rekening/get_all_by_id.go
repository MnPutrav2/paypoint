package rekeningService

import (
	"context"
	rekeningModel "kavi-kasir/internal/model/rekening"

	"github.com/google/uuid"
)

func (s *rekeningService) GetAllByIdService(ctx context.Context, id uuid.UUID) ([]rekeningModel.Rekening, error) {
	result, err := s.repo.GetAllbyId(ctx, id)
	if err != nil {
		return nil, err
	}

	return result, nil
}
