package produkService

import (
	"context"
	"kavi-kasir/internal/model"
	"kavi-kasir/internal/model/entity"
	produkModel "kavi-kasir/internal/model/produk"
	produkRepo "kavi-kasir/internal/repository/produk"

	"github.com/google/uuid"
)

type ProdukService interface {
	Create(ctx context.Context, req produkModel.Produk) (produkModel.Produk, string, error)
	Delete(ctx context.Context, id uuid.UUID) error
	GetByID(ctx context.Context, id uuid.UUID) (entity.ProdukWithKatalog, error)
	GetAllPaginated(ctx context.Context, page, size int, keyword string) ([]entity.ProdukWithKatalog, int, string, error)
	Update(ctx context.Context, id uuid.UUID, req produkModel.ProdukUpdate) (produkModel.ProdukUpdate, error)
	UpdateSelected(ctx context.Context, id uuid.UUID, req map[string]interface{}) (map[string]any, produkModel.Produk, string, error)
	UpdateImage(ctx context.Context, id uuid.UUID, img string) ([]model.UpdateKey, string, error)
}

type produkService struct {
	repo produkRepo.ProdukRepository
}

func NewProdukService(repo produkRepo.ProdukRepository) ProdukService {
	return &produkService{repo: repo}
}
