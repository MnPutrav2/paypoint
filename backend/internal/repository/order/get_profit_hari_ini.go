package orderRepo

import (
	"context"
	orderModel "kavi-kasir/internal/model/order"
)

func (r *orderRepository) GetProfitHariIni(ctx context.Context) (int64, error) {
	var profit int64
	err := r.db.WithContext(ctx).
		Model(&orderModel.OrderItem{}).
		Joins("JOIN orders ON orders.id = order_items.order_id").
		Where("orders.status_id = (SELECT id FROM kategoris WHERE nama = ?) AND DATE(orders.created_at) = CURRENT_DATE", "selesai").
		Select("COALESCE(SUM(order_items.profit), 0)").
		Scan(&profit).Error
	return profit, err
}
