package produkRepo

import (
	"context"
	"kavi-kasir/internal/model"
	"kavi-kasir/internal/model/entity"
	produkModel "kavi-kasir/internal/model/produk"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type produkRepository struct {
	db *gorm.DB
}

type ProdukRepository interface {
	CreateProduk(ctx context.Context, req *produkModel.Produk) (produkModel.Produk, error)
	DeleteProduk(ctx context.Context, id uuid.UUID) error
	GetProdukByIDProduk(ctx context.Context, id uuid.UUID) (entity.ProdukWithKatalog, error)
	GetAllProdukPaginated(ctx context.Context, page, size int, keyword string) ([]entity.ProdukWithKatalog, int, error)
	UpdateProduk(ctx context.Context, id uuid.UUID, req *produkModel.ProdukUpdate) (produkModel.ProdukUpdate, error)
	UpdateSelectedProduk(ctx context.Context, id uuid.UUID, req map[string]interface{}) (map[string]interface{}, produkModel.Produk, error)
	UpdateImageProduk(ctx context.Context, id uuid.UUID, img string) ([]model.UpdateKey, error)
	// Add function in here
}

func NewProdukRepository(db *gorm.DB) ProdukRepository {
	return &produkRepository{db: db}
}
