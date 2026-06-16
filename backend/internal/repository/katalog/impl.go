package katalogRepo

import (
	"context"
	katalogModel "kavi-kasir/internal/model/katalog"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type katalogRepository struct {
	db *gorm.DB
}

type KatalogRepository interface {
	CreateKatalog(ctx context.Context, req *katalogModel.Katalog) (katalogModel.Katalog, error)
	GetAllKatalogPagination(ctx context.Context, page, size int, keyword string) ([]katalogModel.Katalog, int, error)
	GetKatalogById(ctx context.Context, id uuid.UUID) (katalogModel.Katalog, error)
	DeleteKatalog(ctx context.Context, id uuid.UUID, userId uuid.UUID) error
	GetAvailableKatalog(ctx context.Context, id uuid.UUID) bool
	UpdateKatalog(ctx context.Context, id uuid.UUID, harga int) (katalogModel.Katalog, error)
}

func NewKatalogRepository(db *gorm.DB) KatalogRepository {
	return &katalogRepository{db: db}
}
