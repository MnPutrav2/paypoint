package orderRepo

import (
	"context"
	dashboardModel "kavi-kasir/internal/model/dashboard"
	kategoriModel "kavi-kasir/internal/model/kategori"
	orderModel "kavi-kasir/internal/model/order"
	utilConst "kavi-kasir/pkg/util/const"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type orderRepository struct {
	db *gorm.DB
}

type OrderRepository interface {
	BeginTx(ctx context.Context) *gorm.DB
	CreateOrder(ctx context.Context, o orderModel.OrderAdd, customer *string, user uuid.UUID, total int64, invoice string, u uuid.UUID) (orderModel.Order, error)
	// GetAllOrderPaginated(page, size int, keyword string) ([]orderModel.OrderItem, int, error)
	GetAllOrderIdPaginated(ctx context.Context, page, size int, keyword string, sortColumn string, sortDirection string) ([]orderModel.Order, int, error)
	GetOmzetBulanan(ctx context.Context, nBulan int) ([]OmzetBulananRow, error)
	GetOrderItemByOrderId(ctx context.Context, id uuid.UUID) ([]orderModel.OrderItem, error)
	GetOrderDataById(ctx context.Context, id uuid.UUID) (orderModel.Order, error)
	GetOrderPayByOrderId(ctx context.Context, id uuid.UUID) (orderModel.OrderPay, error)
	GetByInvoice(ctx context.Context, inv string) (orderModel.Order, error)
	GetTotalOmzet(ctx context.Context) (int64, error)
	GetProfitHariIni(ctx context.Context) (int64, error)
	GetTotalProfit(ctx context.Context) (int64, error)
	GetItemTerjual(ctx context.Context) (int64, error)
	GetTransaksiBelumSelesai(ctx context.Context) (int64, error)
	GetGrafikOmzet(ctx context.Context, from, to time.Time, mode utilConst.GrafikMode) ([]dashboardModel.Grafik, error)
	GetGrafikItemTerlaris(ctx context.Context, from, to time.Time) ([]dashboardModel.Grafik, error)
	DeleteOrder(ctx context.Context, id uuid.UUID) error
	UpdateOrder(ctx context.Context, id uuid.UUID, status uuid.UUID) (orderModel.Order, error)
	CheckPrice(ctx context.Context, o orderModel.OrderAdd) (int64, error)
	CheckCount(ctx context.Context, t time.Time) (int, error)
	GetKategori(ctx context.Context, keyword string) (kategoriModel.Kategori, error)
	CreateOrderPay(ctx context.Context, data orderModel.OrderPay, statusID uuid.UUID) error
}

func NewOrderRepository(db *gorm.DB) OrderRepository {
	return &orderRepository{db}
}
