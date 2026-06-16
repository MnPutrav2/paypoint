package kategoriRepo

import (
	"context"
	kategoriModel "kavi-kasir/internal/model/kategori"
)

func (q *kategoriRepository) GetAllRefKategoriPaginated(ctx context.Context, page, size int, keyword string) ([]kategoriModel.RefKategori, int, error) {
	var (
		kategori []kategoriModel.RefKategori
		total    int64
	)

	if err := q.db.WithContext(ctx).Model(&kategoriModel.RefKategori{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}

	if err := q.db.WithContext(ctx).Limit(size).Offset(page).Find(&kategori).Error; err != nil {
		return nil, 0, err
	}

	return kategori, int(total), nil
}
