package orderRepo

import (
	"context"
	orderModel "kavi-kasir/internal/model/order"

	"github.com/google/uuid"
)

func (q *orderRepository) DeleteOrder(ctx context.Context, id uuid.UUID) error {
	if err := q.db.WithContext(ctx).Delete(&orderModel.Order{}, "id = ? AND status = 'batal'", id).Error; err != nil {
		return err
	}

	return nil
}
