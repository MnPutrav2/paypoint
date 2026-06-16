package dashboardService

import (
	"context"
	dashboardModel "kavi-kasir/internal/model/dashboard"
	orderRepo "kavi-kasir/internal/repository/order"
	rekomendasiRepo "kavi-kasir/internal/repository/rekomendasi"
	userRepo "kavi-kasir/internal/repository/user"
	utilConst "kavi-kasir/pkg/util/const"
)

type dashboardService struct {
	// repoKat katalogRepo.KatalogRepository
	// repoPro produkRepo.ProdukRepository
	userRepo  userRepo.UserRepository
	orderRepo orderRepo.OrderRepository
	rekomRepo rekomendasiRepo.RekomendasiRepo
}

// GetPrediksi implements [DashboardService].

type DashboardService interface {
	GetDashboard(ctx context.Context, mode utilConst.GrafikMode) (dashboardModel.Dashboard, error)
	GetPrediksi(ctx context.Context) (*dashboardModel.PrediksiOmzet, error)
	GetMarketBasket(ctx context.Context) ([]string, error)
}

func NewDashboardService(userRepo userRepo.UserRepository, orderRepo orderRepo.OrderRepository, rekomRepo rekomendasiRepo.RekomendasiRepo) DashboardService {
	return &dashboardService{userRepo: userRepo, orderRepo: orderRepo, rekomRepo: rekomRepo}
}
