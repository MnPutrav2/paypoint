package produkService

import (
	"context"
	produkModel "kavi-kasir/internal/model/produk"

	"github.com/google/uuid"
)

func (q *produkService) UpdateSelected(ctx context.Context, id uuid.UUID, req map[string]any) (map[string]any, produkModel.Produk, string, error) {
	data, result, err := q.repo.UpdateSelectedProduk(ctx, id, req)
	if err != nil {
		return nil, produkModel.Produk{}, "failed update produk", err
	}

	return data, result, "success", nil
}
