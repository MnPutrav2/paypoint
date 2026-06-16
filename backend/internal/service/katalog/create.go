package katalogService

import (
	"context"
	errorhttp "kavi-kasir/internal/http/error"
	katalogModel "kavi-kasir/internal/model/katalog"
)

func (s *katalogService) CreateKatalogService(ctx context.Context, req *katalogModel.Katalog) (katalogModel.Katalog, error) {

	if s.repo.GetAvailableKatalog(ctx, req.ProdukID) {
		return katalogModel.Katalog{}, errorhttp.ErrAvailableData
	}

	price, err := s.repo2.GetProdukByIDProduk(ctx, req.ProdukID)
	if err != nil {
		return katalogModel.Katalog{}, err
	}

	if req.Harga < price.Harga {
		return katalogModel.Katalog{}, errorhttp.ErrPriceKat
	}

	result, err := s.repo.CreateKatalog(ctx, req)
	if err != nil {
		return katalogModel.Katalog{}, err
	}

	return result, nil
}
