package kategoriRepo

import (
	"context"
	kategoriModel "kavi-kasir/internal/model/kategori"

	"github.com/google/uuid"
)

func (q *kategoriRepository) DeleteRefKategori(ctx context.Context, id uuid.UUID) error {
	if err := q.db.WithContext(ctx).Delete(&kategoriModel.RefKategori{}, "id = ?", id).Error; err != nil {
		return err
	}

	return nil
}
