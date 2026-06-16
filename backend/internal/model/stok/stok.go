package stokModel

import (
	produkModel "kavi-kasir/internal/model/produk"
	"time"

	"github.com/google/uuid"
)

type Stok struct {
	ID        uuid.UUID          `json:"id" gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	ProdukID  uuid.UUID          `json:"produk_id" gorm:"type:uuid;not null"`
	Produk    produkModel.Produk `json:"produk" gorm:"foreignKey:ProdukID;constraint:OnDelete:CASCADE;"`
	Stok      int                `json:"stok" gorm:"type:decimal;not null"`
	CreatedAt time.Time          `json:"-" gorm:"not null;default:now()"`
	UpdatedAt time.Time          `json:"-" gorm:"not null;default:now()"`
}

type StokAdd struct {
	Stok int    `json:"stok" gorm:"type:decimal;not null"`
	Tipe string `json:"tipe"`
}
