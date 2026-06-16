package kategoriRepo

import (
	"context"
	kategoriModel "kavi-kasir/internal/model/kategori"

	"github.com/google/uuid"
)

func (q *kategoriRepository) GetById(ctx context.Context, id uuid.UUID) (kategoriModel.Kategori, error) {
	var kategori kategoriModel.Kategori
	if err := q.db.WithContext(ctx).Model(&kategoriModel.Kategori{}).Where("id = ?", id).Find(&kategori).Error; err != nil {
		return kategoriModel.Kategori{}, err
	}

	return kategori, nil
}
