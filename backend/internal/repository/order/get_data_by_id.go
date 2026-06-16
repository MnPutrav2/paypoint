package orderRepo

import (
	"context"
	orderModel "kavi-kasir/internal/model/order"

	"github.com/google/uuid"
)

func (q *orderRepository) GetOrderDataById(ctx context.Context, id uuid.UUID) (orderModel.Order, error) {
	var order orderModel.Order
	if err := q.db.WithContext(ctx).Model(&orderModel.Order{}).
		Preload("OrderItem").
		Preload("Bayar").
		// Preload("Kategori").
		Preload("Status").Where("id = ?", id).Find(&order).Error; err != nil {
		return orderModel.Order{}, err
	}

	return order, nil
}
