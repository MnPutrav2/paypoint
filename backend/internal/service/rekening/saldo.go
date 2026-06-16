package rekeningService

import (
	"context"
	errorhttp "kavi-kasir/internal/http/error"
	rekeningModel "kavi-kasir/internal/model/rekening"

	"github.com/google/uuid"
)

func (s *rekeningService) SaldoService(ctx context.Context, id uuid.UUID, userId uuid.UUID, saldo rekeningModel.RekeningSaldo) (rekeningModel.Rekening, error) {

	if saldo.Type == "tambah" {
		result, row, err := s.repo.IncrementSaldo(ctx, id, userId, saldo.Saldo)
		if err != nil {
			return rekeningModel.Rekening{}, err
		}

		if row == 0 {
			return rekeningModel.Rekening{}, errorhttp.ErrRek
		}

		return result, nil
	}

	result, row, err := s.repo.DecrementSaldo(ctx, id, userId, saldo.Saldo)
	if err != nil {
		return rekeningModel.Rekening{}, err
	}

	if row == 0 {
		return rekeningModel.Rekening{}, errorhttp.ErrRek
	}

	return result, nil
}
