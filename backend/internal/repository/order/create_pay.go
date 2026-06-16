package orderRepo

import (
	"context"
	orderModel "kavi-kasir/internal/model/order"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

func (r *orderRepository) CreateOrderPay(ctx context.Context, data orderModel.OrderPay, statusID uuid.UUID) error {
	return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		// 1. Create OrderPay
		if err := tx.Create(&data).Error; err != nil {
			return err
		}

		// 2. Update status Order otomatis
		if err := tx.Model(&orderModel.Order{}).
			Where("id = ?", data.OrderID).
			Update("status_id", statusID).Error; err != nil {
			return err
		}

		return nil
	})
}
