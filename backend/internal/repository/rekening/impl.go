package rekeningRepo

import (
	"context"
	rekeningModel "kavi-kasir/internal/model/rekening"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type rekeningRepository struct {
	db *gorm.DB
}

type RekeningRepository interface {
	AddRekening(ctx context.Context, req *rekeningModel.Rekening) (rekeningModel.Rekening, error)
	GetAllPagination(ctx context.Context, page, size int, keyword string) ([]rekeningModel.Rekening, int, error)
	GetAllbyId(ctx context.Context, id uuid.UUID) ([]rekeningModel.Rekening, error)
	DeleteRekening(ctx context.Context, id uuid.UUID, userId uuid.UUID) (int64, error)
	IncrementSaldo(ctx context.Context, id uuid.UUID, userId uuid.UUID, saldo int) (rekeningModel.Rekening, int64, error)
	DecrementSaldo(ctx context.Context, id uuid.UUID, userId uuid.UUID, saldo int) (rekeningModel.Rekening, int64, error)
}

func NewRekeningRepository(db *gorm.DB) RekeningRepository {
	return &rekeningRepository{db: db}
}
