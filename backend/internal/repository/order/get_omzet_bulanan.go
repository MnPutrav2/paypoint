package orderRepo

import (
	"context"
	"time"
)

type OmzetBulananRow struct {
	Tahun int     `gorm:"column:tahun"`
	Bulan int     `gorm:"column:bulan"`
	Total float64 `gorm:"column:total"`
}

func (r *orderRepository) GetOmzetBulanan(ctx context.Context, nBulan int) ([]OmzetBulananRow, error) {
	now := time.Now()

	from := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location()).
		AddDate(0, -nBulan, 0)

	var results []OmzetBulananRow

	err := r.db.WithContext(ctx).
		Table("orders").
		Select(`
			EXTRACT(YEAR FROM created_at)::int AS tahun,
			EXTRACT(MONTH FROM created_at)::int AS bulan,
			COALESCE(SUM(grand_total), 0) AS total
		`).
		Where("created_at >= ?", from).
		Where("orders.status_id = (SELECT id FROM kategoris WHERE nama = ?)", "selesai").
		Group("tahun, bulan").
		Order("tahun ASC, bulan ASC").
		Scan(&results).Error

	if err != nil {
		return nil, err
	}

	return results, nil
}
