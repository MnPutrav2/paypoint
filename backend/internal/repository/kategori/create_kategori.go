package kategoriRepo

import (
	"context"
	kategoriModel "kavi-kasir/internal/model/kategori"
)

func (q *kategoriRepository) CreateKategori(ctx context.Context, kategori *kategoriModel.Kategori) (kategoriModel.Kategori, error) {
	if err := q.db.WithContext(ctx).Create(&kategori).Error; err != nil {
		return kategoriModel.Kategori{}, err
	}

	var data kategoriModel.Kategori
	if err := q.db.WithContext(ctx).Model(&kategoriModel.Kategori{}).Where("id = ?", &kategori.ID).Find(&data).Error; err != nil {
		return kategoriModel.Kategori{}, err
	}

	return data, nil
}
