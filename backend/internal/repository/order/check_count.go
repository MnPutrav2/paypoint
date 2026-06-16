package orderRepo

import (
	"context"
	orderModel "kavi-kasir/internal/model/order"
	"time"
)

func (q *orderRepository) CheckCount(ctx context.Context, t time.Time) (int, error) {
	var i int64

	start := time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, t.Location())
	end := start.Add(24 * time.Hour)
	if err := q.db.WithContext(ctx).Model(&orderModel.Order{}).Where("created_at >= ? AND created_at < ?", start, end).Count(&i).Error; err != nil {
		return 0, err
	}

	return int(i), nil
}
