package orderRepo

import (
	"context"
	orderModel "kavi-kasir/internal/model/order"

	"github.com/google/uuid"
)

func (q orderRepository) GetOrderItemByOrderId(ctx context.Context, id uuid.UUID) ([]orderModel.OrderItem, error) {
	var order []orderModel.OrderItem

	if err := q.db.WithContext(ctx).
		Model(&orderModel.OrderItem{}).
		Preload("Order").
		Preload("Katalog.Produk").
		Find(&order, "order_id = ?", id).
		Error; err != nil {
		return nil, err
	}

	return order, nil
}
