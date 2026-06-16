package bankService

import (
	"context"
	bankModel "kavi-kasir/internal/model/bank"
)

func (s *bankService) GetAllPaginationService(ctx context.Context, page, size int, keyword string) ([]bankModel.Bank, int, string, int, error) {
	result, total, err := s.repo.GetAllPagination(ctx, page, size, keyword)
	if err != nil {
		return nil, 0, "failed get data", 400, err
	}

	return result, total, "success", 200, nil
}
