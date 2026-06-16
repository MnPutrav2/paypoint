package orderRepo

import (
	"context"
	dashboardModel "kavi-kasir/internal/model/dashboard"
	orderModel "kavi-kasir/internal/model/order"
	jwtEnc "kavi-kasir/pkg/auth/jwt"
	utilConst "kavi-kasir/pkg/util/const"
	"time"
)

func (r *orderRepository) GetGrafikOmzet(ctx context.Context, from, to time.Time, mode utilConst.GrafikMode) ([]dashboardModel.Grafik, error) {
	userID := ctx.Value(utilConst.ContextUserID).(*jwtEnc.Claims).UserID
	var selectQuery, groupQuery string

	switch mode {
	case utilConst.GrafikMinggu:
		selectQuery = `EXTRACT(DOW FROM created_at) AS label, COALESCE(SUM(grand_total), 0) AS total`
		groupQuery = `EXTRACT(DOW FROM created_at)`
	case utilConst.GrafikBulan:
		selectQuery = `EXTRACT(DAY FROM created_at) AS label, COALESCE(SUM(grand_total), 0) AS total`
		groupQuery = `EXTRACT(DAY FROM created_at)`
	case utilConst.GrafikTahun:
		selectQuery = `EXTRACT(MONTH FROM created_at) AS label, COALESCE(SUM(grand_total), 0) AS total`
		groupQuery = `EXTRACT(MONTH FROM created_at)`
	}

	var rows []utilConst.GRAFIK_TYPE
	err := r.db.WithContext(ctx).
		Model(&orderModel.Order{}).
		Select(selectQuery).
		Where(
			"user_id = ? AND orders.status_id = (SELECT id FROM kategoris WHERE nama = ?) AND orders.updated_at BETWEEN ? AND ?",
			userID, utilConst.STATUS_PEMBAYARAN["SELESAI"].Label, from, to,
		).
		Group(groupQuery).
		Order(groupQuery).
		Scan(&rows).Error

	if err != nil {
		return nil, err
	}

	return utilConst.MapToGrafik(rows, mode, from), nil
}
