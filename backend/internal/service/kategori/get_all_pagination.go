package kategoriService

import (
	"context"
	kategoriModel "kavi-kasir/internal/model/kategori"
)

func (q *kategoriService) GetAllKategoriPaginated(ctx context.Context, page, size int, keyword string, ref string) ([]kategoriModel.Kategori, int, string, int, error) {

	result, total, err := q.repo.GetAllKategoriPaginated(ctx, page, size, keyword, ref)
	if err != nil {
		return nil, 0, "failed get data", 400, err
	}

	return result, total, "success", 200, nil
}
