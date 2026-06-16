package orderService

import (
	"context"
	orderModel "kavi-kasir/internal/model/order"
)

func (q *orderService) GetAllPaginated(ctx context.Context, page, size int, keyword string,
	sortColumn string,
	sortDirection string) ([]orderModel.Order, int, error) {
	result, total, err := q.repo.GetAllOrderIdPaginated(ctx, page, size, keyword, sortColumn, sortDirection)
	if err != nil {
		return nil, 0, err
	}

	return result, total, nil
}
