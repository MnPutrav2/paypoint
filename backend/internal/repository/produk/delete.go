package produkRepo

import (
	"context"
	produkModel "kavi-kasir/internal/model/produk"

	"github.com/google/uuid"
)

func (q *produkRepository) DeleteProduk(ctx context.Context, id uuid.UUID) error {
	if err := q.db.WithContext(ctx).Model(&produkModel.Produk{}).Where("id = ?", id).Update("is_deleted", true).Error; err != nil {
		return err
	}

	return nil
}
