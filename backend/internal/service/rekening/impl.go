package rekeningService

import (
	"context"
	rekeningModel "kavi-kasir/internal/model/rekening"
	rekeningRepo "kavi-kasir/internal/repository/rekening"

	"github.com/google/uuid"
)

type rekeningService struct {
	repo rekeningRepo.RekeningRepository
}

type RekeningService interface {
	AddRekeningService(ctx context.Context, req *rekeningModel.Rekening) (rekeningModel.Rekening, error)
	GetAllPaginationService(ctx context.Context, page, size int, keyword string) ([]rekeningModel.Rekening, int, error)
	GetAllByIdService(ctx context.Context, id uuid.UUID) ([]rekeningModel.Rekening, error)
	DeleteService(ctx context.Context, id uuid.UUID, userId uuid.UUID) error
	SaldoService(ctx context.Context, id uuid.UUID, userId uuid.UUID, saldo rekeningModel.RekeningSaldo) (rekeningModel.Rekening, error)
}

func NewRekeningService(repo rekeningRepo.RekeningRepository) RekeningService {
	return &rekeningService{repo: repo}
}
