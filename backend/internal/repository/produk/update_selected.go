package produkRepo

import (
	"context"
	"errors"
	produkModel "kavi-kasir/internal/model/produk"

	"github.com/google/uuid"
)

func (q *produkRepository) UpdateSelectedProduk(ctx context.Context, id uuid.UUID, req map[string]any) (map[string]any, produkModel.Produk, error) {

	result := q.db.WithContext(ctx).Model(&produkModel.Produk{}).Where("id = ? AND is_deleted = false", id).Updates(req)
	var produk produkModel.Produk

	if result.Error != nil {
		return nil, produkModel.Produk{}, result.Error
	}

	if result.RowsAffected == 0 {
		return nil, produkModel.Produk{}, errors.New("produk tidak ditemukan")
	}

	if err := q.db.WithContext(ctx).Model(&produkModel.Produk{}).Preload("Kategori").Preload("Kategori.RefKategori").Where("id = ?", id).Find(&produk).Error; err != nil {
		return nil, produkModel.Produk{}, err
	}

	return req, produk, nil
}
