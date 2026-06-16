package orderRepo

import (
	"context"
	orderModel "kavi-kasir/internal/model/order"

	"github.com/google/uuid"
)

func (q *orderRepository) GetOrderPayByOrderId(ctx context.Context, id uuid.UUID) (orderModel.OrderPay, error) {
	var order orderModel.OrderPay
	if err := q.db.WithContext(ctx).Model(&orderModel.OrderPay{}).
		// Preload("Kategori").
		Where("order_id = ?", id).
		Find(&order).Error; err != nil {
		return orderModel.OrderPay{}, err
	}

	return order, nil
}
