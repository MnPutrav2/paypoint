package produkService

import (
	"context"
	"errors"
	"kavi-kasir/internal/model/entity"
)

func (s *produkService) GetAllPaginated(ctx context.Context, page, size int, keyword string) ([]entity.ProdukWithKatalog, int, string, error) {

	result, total, err := s.repo.GetAllProdukPaginated(ctx, page, size, keyword)
	if err != nil {
		if errors.Is(err, context.DeadlineExceeded) {
			return nil, 0, "request time out", err
		}

		return nil, 0, "failed get data", err
	}

	return result, total, "success", nil
}
