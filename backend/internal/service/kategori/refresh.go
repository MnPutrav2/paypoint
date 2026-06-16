package kategoriService

import (
	"context"
	kategoriModel "kavi-kasir/internal/model/kategori"
)

func (s *kategoriService) RefreshReferenceService(ctx context.Context) ([]kategoriModel.Reference, string, int, error) {
	data, err := s.repo.RefreshReference(ctx)
	if err != nil {
		return nil, "failed get data", 400, err
	}

	return data, "success", 200, nil
}
