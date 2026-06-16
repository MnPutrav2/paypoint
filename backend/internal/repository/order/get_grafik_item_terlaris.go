package orderRepo

import (
	"context"
	dashboardModel "kavi-kasir/internal/model/dashboard"
	orderModel "kavi-kasir/internal/model/order"
	jwtEnc "kavi-kasir/pkg/auth/jwt"
	utilConst "kavi-kasir/pkg/util/const"
	"time"
)

func (r *orderRepository) GetGrafikItemTerlaris(ctx context.Context, from, to time.Time) ([]dashboardModel.Grafik, error) {
	userID := ctx.Value(utilConst.ContextUserID).(*jwtEnc.Claims).UserID

	var rows []utilConst.GRAFIK_TYPE
	err := r.db.WithContext(ctx).
		Model(&orderModel.OrderItem{}).
		Joins("JOIN orders ON orders.id = order_items.order_id").
		Joins("JOIN kategoris ON kategoris.id = orders.status_id").
		Where(
			"orders.user_id = ? AND kategoris.nama = ? AND orders.created_at BETWEEN ? AND ?",
			userID,
			utilConst.STATUS_PEMBAYARAN["SELESAI"].Label,
			from,
			to,
		).
		Select("order_items.nama_produk AS label, COALESCE(SUM(order_items.jumlah), 0) AS total").
		Group("order_items.nama_produk").
		Order("total DESC, order_items.nama_produk ASC").
		Limit(5).
		Scan(&rows).Error

	if err != nil {
		return nil, err
	}

	result := make([]dashboardModel.Grafik, len(rows))
	for i, row := range rows {
		result[i] = dashboardModel.Grafik{
			Label: row.Label,
			Value: row.Value,
		}
	}

	return result, nil
}
