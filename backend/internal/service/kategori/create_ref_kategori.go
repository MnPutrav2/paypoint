package kategoriService

import (
	"context"
	kategoriModel "kavi-kasir/internal/model/kategori"
)

func (s *kategoriService) CreateRefKategoriService(ctx context.Context, kategori *kategoriModel.RefKategori) (kategoriModel.RefKategori, string, int, error) {
	result, err := s.repo.CreateRefKategori(ctx, kategori)
	if err != nil {
		return kategoriModel.RefKategori{}, "failed create ref kategori", 400, err
	}

	return result, "success", 200, nil
}
