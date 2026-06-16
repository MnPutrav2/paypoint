package produkService

import (
	"context"
	produkModel "kavi-kasir/internal/model/produk"
)

func (s *produkService) Create(ctx context.Context, req produkModel.Produk) (produkModel.Produk, string, error) {

	data, err := s.repo.CreateProduk(ctx, &req)
	if err != nil {
		return produkModel.Produk{}, "failed create produk", err
	}

	return data, "success", nil
}
