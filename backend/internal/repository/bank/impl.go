package bankRepo

import (
	"context"
	bankModel "kavi-kasir/internal/model/bank"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type bankRepository struct {
	db *gorm.DB
}

type BankRepository interface {
	AddBank(ctx context.Context, req *bankModel.Bank) (bankModel.Bank, error)
	GetAllPagination(ctx context.Context, page, size int, keyword string) ([]bankModel.Bank, int, error)
	GetAllbyId(ctx context.Context, id uuid.UUID) ([]bankModel.Bank, error)
	DeleteBank(ctx context.Context, id uuid.UUID) (int64, error)
	UpdateBank(ctx context.Context, id uuid.UUID, req *bankModel.BankUpdate) (bankModel.BankUpdate, error)
}

func NewBankRepository(db *gorm.DB) BankRepository {
	return &bankRepository{db: db}
}
