package kategoriService

import (
	"context"
	kategoriModel "kavi-kasir/internal/model/kategori"
)

func (s *kategoriService) CreateKategoriService(ctx context.Context, kategori *kategoriModel.Kategori) (kategoriModel.Kategori, string, int, error) {
	result, err := s.repo.CreateKategori(ctx, kategori)
	if err != nil {
		return kategoriModel.Kategori{}, "failed create kategori", 400, err
	}

	return result, "success", 200, nil
}
