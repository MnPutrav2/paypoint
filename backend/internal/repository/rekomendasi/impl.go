package rekomendasiRepo

import (
	"context"
	produkModel "kavi-kasir/internal/model/produk"

	"gorm.io/gorm"
)

type rekomendasiRepo struct {
	db *gorm.DB
}

type RekomendasiRepo interface {
	GetProduk(ctx context.Context) ([][]string, error)
	GetAllProduk(ctx context.Context) ([]produkModel.Produk, error)
}

func NewRekomendasiRepo(db *gorm.DB) RekomendasiRepo {
	return &rekomendasiRepo{db: db}
}
