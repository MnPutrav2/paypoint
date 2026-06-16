package produkModel

import (
	"time"

	kategori_model "kavi-kasir/internal/model/kategori"

	"github.com/google/uuid"
)

type Produk struct {
	ID         uuid.UUID               `json:"id" gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	Nama       string                  `json:"nama" gorm:"type:varchar(255);not null"`
	Detail     string                  `json:"detail" gorm:"type:text;not null"`
	Foto       string                  `json:"foto" gorm:"type:varchar(255);not null"`
	Harga      int                     `json:"harga" gorm:"type:decimal;not null"`
	KategoriID uuid.UUID               `json:"kategori_id" gorm:"type:uuid;not null"`
	Kategori   kategori_model.Kategori `json:"kategori" gorm:"foreignKey:KategoriID;constraint:OnDelete:CASCADE;"`
	IsDeleted  bool                    `gorm:"default:false" json:"-"`
	Terjual    int                     `json:"terjual" gorm:"type:decimal;null;default:0"`
	CreatedAt  time.Time               `json:"-" gorm:"not null;default:now()"`
	UpdatedAt  time.Time               `json:"-" gorm:"not null;default:now()"`
}

type ProdukShow struct {
	ID       uuid.UUID                    `json:"id"`
	Nama     string                       `json:"nama"`
	Detail   string                       `json:"detail"`
	Foto     string                       `json:"foto"`
	Harga    int                          `json:"harga"`
	Terjual  int                          `json:"terjual"`
	Kategori *kategori_model.KategoriShow `json:"kategori"`
}

type ProdukUpdate struct {
	Nama       string    `json:"nama" gorm:"type:varchar(255);not null"`
	Detail     string    `json:"detail" gorm:"type:text;not null"`
	Foto       string    `json:"foto" gorm:"type:varchar(255);not null"`
	Harga      int       `json:"harga" gorm:"type:decimal;not null"`
	KategoriID uuid.UUID `json:"kategori_id" gorm:"type:uuid;not null"`
}

type ProdukPatch struct {
	Nama       *string    `json:"nama" gorm:"type:varchar(255);not null"`
	Detail     *string    `json:"detail" gorm:"type:text;not null"`
	Foto       *string    `json:"foto" gorm:"type:varchar(255);not null"`
	Harga      *int       `json:"harga" gorm:"type:decimal;not null"`
	KategoriID *uuid.UUID `json:"kategori_id" gorm:"type:uuid;not null"`
}

type ProdukTest struct {
	Nama       string    `json:"nama" gorm:"type:varchar(255);not null"`
	Detail     string    `json:"detail" gorm:"type:text;not null"`
	Foto       string    `json:"foto" gorm:"type:varchar(255);not null"`
	Harga      int       `json:"harga" gorm:"type:decimal;not null"`
	KategoriID uuid.UUID `json:"kategori_id" gorm:"type:uuid;not null"`
}
