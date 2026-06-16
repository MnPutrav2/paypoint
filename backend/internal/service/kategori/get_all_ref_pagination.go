package kategoriService

import (
	"context"
	kategoriModel "kavi-kasir/internal/model/kategori"
)

func (q *kategoriService) GetAllRefKategoriPaginated(ctx context.Context, page, size int, keyword string) ([]kategoriModel.RefKategori, int, string, int, error) {
	result, total, err := q.repo.GetAllRefKategoriPaginated(ctx, page, size, keyword)
	if err != nil {
		return nil, 0, "failed get data", 400, err
	}

	return result, total, "success", 200, nil
}
