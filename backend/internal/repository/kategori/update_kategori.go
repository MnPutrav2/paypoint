package kategoriRepo

import (
	"context"
	kategoriModel "kavi-kasir/internal/model/kategori"

	"github.com/google/uuid"
)

func (q *kategoriRepository) UpdateKategori(ctx context.Context, id uuid.UUID, data kategoriModel.KategoriCreate) (kategoriModel.Kategori, error) {
	var result kategoriModel.Kategori

	if err := q.db.WithContext(ctx).Model(&kategoriModel.Kategori{}).Where("id = ?", id).Updates(data).Error; err != nil {
		return kategoriModel.Kategori{}, err
	}

	if err := q.db.WithContext(ctx).Model(&kategoriModel.Kategori{}).Preload("RefKategori").Where("id = ?", id).Find(&result).Error; err != nil {
		return kategoriModel.Kategori{}, err
	}

	return result, nil
}
