package orderRepo

import (
	"context"
	orderModel "kavi-kasir/internal/model/order"
)

func (r *orderRepository) GetTransaksiBelumSelesai(ctx context.Context) (int64, error) {
	var total int64
	err := r.db.WithContext(ctx).
		Model(&orderModel.Order{}).
		Where("status_id != (SELECT id FROM kategoris WHERE nama = ?)", "selesai").
		Count(&total).Error
	return total, err
}
