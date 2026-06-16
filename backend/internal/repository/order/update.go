package orderRepo

import (
	"context"
	orderModel "kavi-kasir/internal/model/order"

	"github.com/google/uuid"
)

func (repo *orderRepository) UpdateOrder(ctx context.Context, id uuid.UUID, status uuid.UUID) (orderModel.Order, error) {
	q := repo.db.Model(&orderModel.Order{}).Preload("Bayar").Preload("OrderItem").Preload("Status").Where("id = ?", id)
	if err := q.Update("status_id", status).Error; err != nil {
		return orderModel.Order{}, err
	}

	var order orderModel.Order
	if err := q.Find(&order).Error; err != nil {
		return orderModel.Order{}, err
	}

	return order, nil
}
