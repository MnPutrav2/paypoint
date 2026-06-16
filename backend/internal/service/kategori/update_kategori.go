package kategoriService

import (
	"context"
	kategoriModel "kavi-kasir/internal/model/kategori"

	"github.com/google/uuid"
)

func (s *kategoriService) UpdateKategoriService(ctx context.Context, id uuid.UUID, data kategoriModel.KategoriCreate) (kategoriModel.Kategori, string, int, error) {
	result, err := s.repo.UpdateKategori(ctx, id, data)
	if err != nil {
		return kategoriModel.Kategori{}, "failed update data", 400, err
	}

	return result, "success", 200, nil
}
