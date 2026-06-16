package produkRepo

import (
	"context"
	produkModel "kavi-kasir/internal/model/produk"
	stokModel "kavi-kasir/internal/model/stok"
)

func (q *produkRepository) CreateProduk(ctx context.Context, req *produkModel.Produk) (produkModel.Produk, error) {

	if err := q.db.WithContext(ctx).Create(req).Error; err != nil {
		return produkModel.Produk{}, err
	}

	stok := stokModel.Stok{
		ProdukID: req.ID,
		Stok:     0,
	}

	if err := q.db.WithContext(ctx).Create(&stok).Error; err != nil {
		return produkModel.Produk{}, err
	}

	var produk produkModel.Produk
	if err := q.db.WithContext(ctx).Preload("Kategori").Preload("Kategori.RefKategori").Model(&produkModel.Produk{}).Where("id = ?", req.ID).First(&produk).Error; err != nil {
		return produkModel.Produk{}, err
	}

	return produk, nil
}
