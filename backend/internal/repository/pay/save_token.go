package payRepo

import (
	"context"
	orderModel "kavi-kasir/internal/model/order"

	"github.com/google/uuid"
)

func (q *payRepository) SaveToken(ctx context.Context, inv uuid.UUID, token uuid.UUID) error {

	if err := q.db.WithContext(ctx).Model(orderModel.OrderPay{}).Where("order_id = ?", inv).Update("token", token).Error; err != nil {
		return err
	}

	return nil
}
