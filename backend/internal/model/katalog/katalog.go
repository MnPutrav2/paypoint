package katalogModel

import (
	produkModel "kavi-kasir/internal/model/produk"
	userModel "kavi-kasir/internal/model/user"
	"time"

	"github.com/google/uuid"
)

type Katalog struct {
	ID        uuid.UUID          `json:"id" gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	UserID    uuid.UUID          `json:"user_id" gorm:"type:uuid;not null"`
	User      userModel.User     `json:"user" gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
	ProdukID  uuid.UUID          `json:"produk_id" gorm:"type:uuid;not null"`
	Produk    produkModel.Produk `json:"produk" gorm:"foreignKey:ProdukID;constraint:OnDelete:CASCADE"`
	Harga     int                `json:"harga" gorm:"type:decimal;not null"`
	CreatedAt time.Time          `json:"-" gorm:"not null;default:now()"`
	UpdatedAt time.Time          `json:"-" gorm:"not null;default:now()"`
}

type KatalogCreateRequest struct {
	ProdukID uuid.UUID `json:"produk_id"`
	Harga    int       `json:"harga"`
}

type KatalogCreate struct {
	UserID   uuid.UUID `json:"user_id"`
	ProdukID uuid.UUID `json:"produk_id"`
	Harga    int       `json:"harga"`
}

type KatalogShow struct {
	ID           uuid.UUID              `json:"id"`
	Produk       produkModel.ProdukShow `json:"produk"`
	HargaKatalog int                    `json:"harga_katalog"`
}

type UpdateKatalog struct {
	Harga int `json:"harga"`
}
