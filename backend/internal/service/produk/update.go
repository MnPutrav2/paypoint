package produkService

import (
	"context"
	produkModel "kavi-kasir/internal/model/produk"

	"github.com/google/uuid"
)

func (s *produkService) Update(ctx context.Context, id uuid.UUID, req produkModel.ProdukUpdate) (produkModel.ProdukUpdate, error) {
	data, err := s.repo.UpdateProduk(ctx, id, &req)
	if err != nil {
		return produkModel.ProdukUpdate{}, err
	}

	return data, nil
}
