package bankService

import (
	"context"
	bankModel "kavi-kasir/internal/model/bank"
	bankRepo "kavi-kasir/internal/repository/bank"

	"github.com/google/uuid"
)

type bankService struct {
	repo bankRepo.BankRepository
}

type BankService interface {
	AddBankService(ctx context.Context, req *bankModel.Bank) (bankModel.Bank, string, int, error)
	GetAllPaginationService(ctx context.Context, page, size int, keyword string) ([]bankModel.Bank, int, string, int, error)
	GetAllByIdService(ctx context.Context, id uuid.UUID) ([]bankModel.Bank, string, int, error)
	DeleteService(ctx context.Context, id uuid.UUID) (string, int, error)
	UpdateBankService(ctx context.Context, id uuid.UUID, req bankModel.BankUpdate) (bankModel.BankUpdate, error)
}

func NewBankService(repo bankRepo.BankRepository) BankService {
	return &bankService{repo: repo}
}
