package rekeningService

import (
	"context"
	rekeningModel "kavi-kasir/internal/model/rekening"
)

func (s *rekeningService) AddRekeningService(ctx context.Context, req *rekeningModel.Rekening) (rekeningModel.Rekening, error) {
	result, err := s.repo.AddRekening(ctx, req)
	if err != nil {
		return rekeningModel.Rekening{}, err
	}

	return result, nil
}
