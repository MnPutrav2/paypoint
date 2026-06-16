package payService

import (
	"context"
	midtransModel "kavi-kasir/internal/model/midtrans"
	payModel "kavi-kasir/internal/model/pay"
	kategoriRepo "kavi-kasir/internal/repository/kategori"
	orderRepo "kavi-kasir/internal/repository/order"
	payRepo "kavi-kasir/internal/repository/pay"

	"github.com/google/uuid"
)

type payService struct {
	repo    payRepo.PayRepository
	repo2   orderRepo.OrderRepository
	repoKat kategoriRepo.KategoriReposiory
}

type PayService interface {
	CreatePayment(ctx context.Context, payload payModel.PayRequest) (payModel.PayResponse, error)
	MidtransWebhook(ctx context.Context, body midtransModel.MidtransWebhook) error
	Update(ctx context.Context, status string, id uuid.UUID) error
}

func NewPayService(repo payRepo.PayRepository, repo2 orderRepo.OrderRepository, repoKat kategoriRepo.KategoriReposiory) PayService {
	return &payService{repo: repo, repo2: repo2, repoKat: repoKat}
}
