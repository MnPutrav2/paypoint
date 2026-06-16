package orderRepo

import (
	"context"
	orderModel "kavi-kasir/internal/model/order"
)

func (q *orderRepository) GetByInvoice(ctx context.Context, inv string) (orderModel.Order, error) {
	var data orderModel.Order

	if err := q.db.WithContext(ctx).Model(&orderModel.Order{}).Where("invoice = ?", inv).Find(&data).Error; err != nil {
		return orderModel.Order{}, err
	}

	return data, nil
}
