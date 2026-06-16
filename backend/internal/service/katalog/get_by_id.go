package katalogService

import (
	"context"
	katalogModel "kavi-kasir/internal/model/katalog"

	"github.com/google/uuid"
)

func (s *katalogService) GetKatalogByIdService(ctx context.Context, id uuid.UUID) (katalogModel.Katalog, error) {
	result, err := s.repo.GetKatalogById(ctx, id)
	if err != nil {
		return katalogModel.Katalog{}, err
	}

	return result, nil
}
