package payRepo

import (
	"context"
	orderModel "kavi-kasir/internal/model/order"

	"github.com/google/uuid"
)

func (q *payRepository) GetOrderList(ctx context.Context, inv uuid.UUID) (orderModel.Order, []orderModel.OrderItem, error) {
	var (
		data orderModel.Order
		list []orderModel.OrderItem
	)

	if err := q.db.WithContext(ctx).Model(&orderModel.Order{}).
		Preload("Status").
		Where("id = ?", inv).Find(&data).Error; err != nil {
		return orderModel.Order{}, nil, err
	}

	if err := q.db.WithContext(ctx).Model(&orderModel.OrderItem{}).
		// Preload("Produk").
		Preload("Katalog").
		Preload("Katalog.Produk").
		Where("order_id = ?", inv).Find(&list).Error; err != nil {
		return orderModel.Order{}, nil, err
	}

	return data, list, nil
}
