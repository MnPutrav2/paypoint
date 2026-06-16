package katalogService

import (
	"context"
	katalogModel "kavi-kasir/internal/model/katalog"
)

func (q *katalogService) GetAllKatalogPaginatedService(ctx context.Context, page, size int, keyword string) ([]katalogModel.Katalog, int, error) {
	result, total, err := q.repo.GetAllKatalogPagination(ctx, page, size, keyword)
	if err != nil {
		return nil, 0, err
	}

	return result, total, nil
}
