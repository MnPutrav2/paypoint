package stokRepo

import (
	stokModel "kavi-kasir/internal/model/stok"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type stokRepository struct {
	db *gorm.DB
}

type StokRepository interface {
	UpdateStok(id uuid.UUID, stok stokModel.StokAdd) error
	UpdateStokData(id uuid.UUID, stok stokModel.StokAdd) error
	CheckStock(id uuid.UUID, stok int) error
	DecrementStok(id uuid.UUID, stok int) error
	// Add function in here
}

func NewStokRepository(db *gorm.DB) StokRepository {
	return &stokRepository{db}
}
