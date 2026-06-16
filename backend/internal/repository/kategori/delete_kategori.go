package kategoriRepo

import (
	"context"
	kategoriModel "kavi-kasir/internal/model/kategori"

	"github.com/google/uuid"
)

func (q *kategoriRepository) DeleteKategori(ctx context.Context, id uuid.UUID) error {
	if err := q.db.WithContext(ctx).Delete(&kategoriModel.Kategori{}, "id = ?", id).Error; err != nil {
		return err
	}

	return nil
}
