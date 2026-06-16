package kategoriRepo

import (
	"context"
	kategoriModel "kavi-kasir/internal/model/kategori"
)

func (q *kategoriRepository) CreateRefKategori(ctx context.Context, kategori *kategoriModel.RefKategori) (kategoriModel.RefKategori, error) {
	if err := q.db.WithContext(ctx).Create(&kategori).Error; err != nil {
		return kategoriModel.RefKategori{}, err
	}

	return *kategori, nil
}
