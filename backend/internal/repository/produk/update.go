package produkRepo

import (
	"context"
	produkModel "kavi-kasir/internal/model/produk"

	"github.com/google/uuid"
)

func (q *produkRepository) UpdateProduk(ctx context.Context, id uuid.UUID, req *produkModel.ProdukUpdate) (produkModel.ProdukUpdate, error) {
	if err := q.db.WithContext(ctx).Model(&produkModel.Produk{}).Where("id = ?", id).Updates(req).Error; err != nil {
		return produkModel.ProdukUpdate{}, err
	}

	return *req, nil
}
