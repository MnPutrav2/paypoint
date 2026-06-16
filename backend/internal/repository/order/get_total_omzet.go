package orderRepo

import (
	"context"
	orderModel "kavi-kasir/internal/model/order"
)

func (r *orderRepository) GetTotalOmzet(ctx context.Context) (int64, error) {
	var total int64
	err := r.db.WithContext(ctx).
		Model(&orderModel.OrderPay{}).
		Joins("JOIN orders ON orders.id = order_pays.order_id").
		Where("orders.status_id = (SELECT id FROM kategoris WHERE nama = ?)", "selesai").
		Select("COALESCE(SUM(order_pays.total), 0)").
		Scan(&total).Error
	return total, err
}
