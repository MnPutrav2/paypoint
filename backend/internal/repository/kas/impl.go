package kasRepo

import (
	"context"
	kasModel "kavi-kasir/internal/model/kas"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type KasRepository interface {
	Tambah(ctx context.Context, userID uuid.UUID, jumlah int64, keterangan string) error
	Kurang(ctx context.Context, userID uuid.UUID, jumlah int64, keterangan string) error
	GetRiwayat(ctx context.Context, userID uuid.UUID) ([]kasModel.Kas, error)
}

type kasRepository struct {
	db *gorm.DB
}

func NewKasRepository(db *gorm.DB) KasRepository {
	return &kasRepository{db}
}
