package orderService

import (
	"context"
	orderModel "kavi-kasir/internal/model/order"

	"github.com/google/uuid"
)

func (s *orderService) GetByID(ctx context.Context, id uuid.UUID) ([]orderModel.OrderItem, error) {
	result, err := s.repo.GetOrderItemByOrderId(ctx, id)
	if err != nil {
		return nil, err
	}

	return result, nil
}
