package kategoriRepo

import (
	"context"
	kategoriModel "kavi-kasir/internal/model/kategori"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type kategoriRepository struct {
	db *gorm.DB
}

type KategoriReposiory interface {
	CreateKategori(ctx context.Context, kategori *kategoriModel.Kategori) (kategoriModel.Kategori, error)
	CreateRefKategori(ctx context.Context, kategori *kategoriModel.RefKategori) (kategoriModel.RefKategori, error)
	GetAllKategoriPaginated(ctx context.Context, page, size int, keyword string, ref string) ([]kategoriModel.Kategori, int, error)
	GetAllRefKategoriPaginated(ctx context.Context, page, size int, keyword string) ([]kategoriModel.RefKategori, int, error)
	DeleteKategori(ctx context.Context, id uuid.UUID) error
	DeleteRefKategori(ctx context.Context, id uuid.UUID) error
	GetById(ctx context.Context, id uuid.UUID) (kategoriModel.Kategori, error)
	Get(ctx context.Context, ref string, keyword string) (kategoriModel.Kategori, error)
	RefreshReference(ctx context.Context) ([]kategoriModel.Reference, error)
	RefreshReferenceData(ctx context.Context, tm time.Time) ([]kategoriModel.Reference, string, error)
	RefreshReferenceAllData(ctx context.Context) ([]kategoriModel.Reference, string, error)
	RefreshReferenceLast(ctx context.Context) (time.Time, time.Time, error)
	UpdateRefKategori(ctx context.Context, id uuid.UUID, data kategoriModel.RefKategoriCreate) (kategoriModel.RefKategoriCreate, error)
	UpdateKategori(ctx context.Context, id uuid.UUID, data kategoriModel.KategoriCreate) (kategoriModel.Kategori, error)
}

func NewKategoryRepository(db *gorm.DB) KategoriReposiory {
	return &kategoriRepository{db: db}
}
