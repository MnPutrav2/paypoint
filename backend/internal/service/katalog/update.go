package katalogService

import (
	"context"
	errorhttp "kavi-kasir/internal/http/error"
	katalogModel "kavi-kasir/internal/model/katalog"

	"github.com/google/uuid"
)

func (s *katalogService) UpdateKatalogService(ctx context.Context, id, userId uuid.UUID, harga int) (katalogModel.Katalog, error) {
	data, err := s.repo.GetKatalogById(ctx, id)
	if err != nil {
		return katalogModel.Katalog{}, err
	}

	if userId != data.UserID {
		return katalogModel.Katalog{}, errorhttp.ErrForbidden
	}

	if harga < data.Produk.Harga {
		return katalogModel.Katalog{}, errorhttp.ErrKatalogPrice
	}

	result, err := s.repo.UpdateKatalog(ctx, id, harga)
	if err != nil {
		return katalogModel.Katalog{}, err
	}

	return result, nil
}
