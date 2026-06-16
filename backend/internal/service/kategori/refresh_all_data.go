package kategoriService

import (
	"context"
	kategoriModel "kavi-kasir/internal/model/kategori"
)

func (s *kategoriService) RefreshReferenceDataAllService(ctx context.Context) ([]kategoriModel.Reference, string, error) {
	data, last, err := s.repo.RefreshReferenceAllData(ctx)
	if err != nil {
		return nil, "", err
	}

	return data, last, nil
}
