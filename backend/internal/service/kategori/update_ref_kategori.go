package kategoriService

import (
	"context"
	kategoriModel "kavi-kasir/internal/model/kategori"

	"github.com/google/uuid"
)

func (s *kategoriService) UpdateRefKategoriService(ctx context.Context, id uuid.UUID, data kategoriModel.RefKategoriCreate) (kategoriModel.RefKategoriCreate, string, int, error) {
	d, err := s.repo.UpdateRefKategori(ctx, id, data)
	if err != nil {
		return kategoriModel.RefKategoriCreate{}, "failed update data", 400, err
	}

	return d, "success", 200, nil
}
