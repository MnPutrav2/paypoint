package katalogService

import (
	"context"
	katalogModel "kavi-kasir/internal/model/katalog"
	katalogRepo "kavi-kasir/internal/repository/katalog"
	produkRepo "kavi-kasir/internal/repository/produk"

	"github.com/google/uuid"
)

type katalogService struct {
	repo  katalogRepo.KatalogRepository
	repo2 produkRepo.ProdukRepository
}

type KatalogService interface {
	CreateKatalogService(ctx context.Context, req *katalogModel.Katalog) (katalogModel.Katalog, error)                      // final
	GetAllKatalogPaginatedService(ctx context.Context, page, size int, keyword string) ([]katalogModel.Katalog, int, error) // final
	DeleteKatalogService(ctx context.Context, id uuid.UUID, userId uuid.UUID) error                                         // final
	GetKatalogByIdService(ctx context.Context, id uuid.UUID) (katalogModel.Katalog, error)                                  // final
	UpdateKatalogService(ctx context.Context, id, userId uuid.UUID, harga int) (katalogModel.Katalog, error)                // final
}

func NewKatalogService(repo katalogRepo.KatalogRepository, repo2 produkRepo.ProdukRepository) KatalogService {
	return &katalogService{repo: repo, repo2: repo2}
}
