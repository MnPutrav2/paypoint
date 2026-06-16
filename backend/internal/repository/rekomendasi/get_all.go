package rekomendasiRepo

import (
	"context"
	produkModel "kavi-kasir/internal/model/produk"
)

func (r *rekomendasiRepo) GetAllProduk(ctx context.Context) ([]produkModel.Produk, error) {
	var data []produkModel.Produk
	if err := r.db.WithContext(ctx).Model(&produkModel.Produk{}).Find(&data).Error; err != nil {
		return nil, err
	}

	return data, nil
}
