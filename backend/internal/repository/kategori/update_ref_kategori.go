package kategoriRepo

import (
	"context"
	kategoriModel "kavi-kasir/internal/model/kategori"

	"github.com/google/uuid"
)

func (q *kategoriRepository) UpdateRefKategori(ctx context.Context, id uuid.UUID, data kategoriModel.RefKategoriCreate) (kategoriModel.RefKategoriCreate, error) {
	if err := q.db.WithContext(ctx).Model(&kategoriModel.RefKategori{}).Where("id = ?", id).Updates(data).Error; err != nil {
		return kategoriModel.RefKategoriCreate{}, err
	}

	return data, nil
}
