package payRepo

import (
	"context"
	orderModel "kavi-kasir/internal/model/order"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type payRepository struct {
	db *gorm.DB
}

type PayRepository interface {
	BeginTx(ctx context.Context) *gorm.DB
	SaveToken(ctx context.Context, inv uuid.UUID, token uuid.UUID) error
	GetOrderList(ctx context.Context, inv uuid.UUID) (orderModel.Order, []orderModel.OrderItem, error)
}

func NewPayRepository(db *gorm.DB) PayRepository {
	return &payRepository{db: db}
}
