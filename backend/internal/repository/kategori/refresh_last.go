package kategoriRepo

import (
	"context"
	kategoriModel "kavi-kasir/internal/model/kategori"
	"time"
)

func (q *kategoriRepository) RefreshReferenceLast(ctx context.Context) (time.Time, time.Time, error) {
	var (
		lastref kategoriModel.RefKategori
		lastkat kategoriModel.Kategori
	)

	if err := q.db.WithContext(ctx).Model(&kategoriModel.RefKategori{}).Order("updated_at DESC").Limit(1).Find(&lastref).Error; err != nil {
		return time.Time{}, time.Time{}, err
	}

	if err := q.db.WithContext(ctx).Model(&kategoriModel.Kategori{}).Order("updated_at DESC").Limit(1).Find(&lastkat).Error; err != nil {
		return time.Time{}, time.Time{}, err
	}

	return lastref.UpdatedAt, lastkat.UpdatedAt, nil
}
