package kategoriService

import (
	"context"
	kategoriModel "kavi-kasir/internal/model/kategori"
	kategoriRepo "kavi-kasir/internal/repository/kategori"
	"time"

	"github.com/google/uuid"
)

type kategoriService struct {
	repo kategoriRepo.KategoriReposiory
}

type KategoriService interface {
	CreateKategoriService(ctx context.Context, kategori *kategoriModel.Kategori) (kategoriModel.Kategori, string, int, error)
	CreateRefKategoriService(ctx context.Context, kategori *kategoriModel.RefKategori) (kategoriModel.RefKategori, string, int, error)
	GetById(ctx context.Context, id uuid.UUID) (kategoriModel.Kategori, error)
	GetAllKategoriPaginated(ctx context.Context, page, size int, keyword string, ref string) ([]kategoriModel.Kategori, int, string, int, error)
	GetAllRefKategoriPaginated(ctx context.Context, page, size int, keyword string) ([]kategoriModel.RefKategori, int, string, int, error)
	DeleteKategoriService(ctx context.Context, id uuid.UUID) (string, int, error)
	DeleteRefKategoriService(ctx context.Context, id uuid.UUID) (string, int, error)
	RefreshReferenceService(ctx context.Context) ([]kategoriModel.Reference, string, int, error)
	RefreshReferenceDataService(ctx context.Context, tm *time.Time) ([]kategoriModel.Reference, string, error)
	RefreshReferenceDataAllService(ctx context.Context) ([]kategoriModel.Reference, string, error)
	UpdateRefKategoriService(ctx context.Context, id uuid.UUID, data kategoriModel.RefKategoriCreate) (kategoriModel.RefKategoriCreate, string, int, error)
	UpdateKategoriService(ctx context.Context, id uuid.UUID, data kategoriModel.KategoriCreate) (kategoriModel.Kategori, string, int, error)
}

func NewKategoriService(repo kategoriRepo.KategoriReposiory) KategoriService {
	return &kategoriService{repo: repo}
}
