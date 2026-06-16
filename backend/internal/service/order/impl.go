package orderService

import (
	"context"
	dashboardModel "kavi-kasir/internal/model/dashboard"
	orderModel "kavi-kasir/internal/model/order"
	katalogRepo "kavi-kasir/internal/repository/katalog"
	kategoriRepo "kavi-kasir/internal/repository/kategori"
	orderRepo "kavi-kasir/internal/repository/order"
	stokRepo "kavi-kasir/internal/repository/stok"
	userRepo "kavi-kasir/internal/repository/user"
	utilConst "kavi-kasir/pkg/util/const"

	"github.com/google/uuid"
)

type OrderService interface {
	Create(ctx context.Context, o orderModel.OrderAdd, user uuid.UUID, total int64) (orderModel.Order, error)
	Delete(ctx context.Context, id uuid.UUID) error
	GetAllPaginated(ctx context.Context, page, size int, keyword string,
		sortColumn string,
		sortDirection string) ([]orderModel.Order, int, error)
	GetByID(ctx context.Context, id uuid.UUID) ([]orderModel.OrderItem, error)
	GetGrafikOmzet(ctx context.Context, mode utilConst.GrafikMode) ([]dashboardModel.Grafik, error)
	GetGrafikItemTerlaris(ctx context.Context, mode utilConst.GrafikMode) ([]dashboardModel.Grafik, error)
	UpdateOrder(ctx context.Context, id uuid.UUID, status string) (orderModel.Order, error)
}

type orderService struct {
	repo     orderRepo.OrderRepository
	kat      katalogRepo.KatalogRepository
	stok     stokRepo.StokRepository
	repoRef  kategoriRepo.KategoriReposiory
	repoUser userRepo.UserRepository
}

func NewOrderService(repo orderRepo.OrderRepository, katalog katalogRepo.KatalogRepository, stok stokRepo.StokRepository, repoRef kategoriRepo.KategoriReposiory, repoUser userRepo.UserRepository) OrderService {
	return &orderService{repo: repo, kat: katalog, stok: stok, repoRef: repoRef, repoUser: repoUser}
}
