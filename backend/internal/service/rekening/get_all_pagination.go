package rekeningService

import (
	"context"
	rekeningModel "kavi-kasir/internal/model/rekening"
)

func (s *rekeningService) GetAllPaginationService(ctx context.Context, page, size int, keyword string) ([]rekeningModel.Rekening, int, error) {
	result, total, err := s.repo.GetAllPagination(ctx, page, size, keyword)
	if err != nil {
		return nil, 0, err
	}

	return result, total, nil
}
