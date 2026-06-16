package kategoriModel

import (
	"time"

	"github.com/google/uuid"
)

type RefKategori struct {
	ID        uuid.UUID `json:"id" gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	Nama      string    `json:"nama" gorm:"type:varchar(100);not null"`
	CreatedAt time.Time `json:"-" gorm:"not null;default:now()"`
	UpdatedAt time.Time `json:"-" gorm:"not null;default:now()"`
}

type RefKategoriShow struct {
	ID   uuid.UUID `json:"id"`
	Nama string    `json:"nama"`
}
type RefSeed struct {
	Nama   string `json:"nama"`
	Values []struct {
		Nama      string `json:"nama"`
		Deskripsi string `json:"deskripsi"`
	} `json:"values"`
}

type Kategori struct {
	ID            uuid.UUID   `json:"id" gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	Nama          string      `json:"nama" gorm:"type:varchar(255);not null"`
	Deskripsi     string      `json:"deskripsi" gorm:"type:text"`
	RefKategoriID uuid.UUID   `json:"-" gorm:"type:uuid;not null"`
	RefKategori   RefKategori `json:"ref_kategori" gorm:"foreignKey:RefKategoriID;constraint:OnDelete:CASCADE;"`
	CreatedAt     time.Time   `json:"-" gorm:"not null;default:now()"`
	UpdatedAt     time.Time   `json:"-" gorm:"not null;default:now()"`
}

type KategoriShow struct {
	ID          uuid.UUID       `json:"id"`
	Nama        string          `json:"nama"`
	Deskripsi   string          `json:"deskripsi"`
	RefKategori RefKategoriShow `json:"ref_kategori"`
}

type RefKategoriCreate struct {
	Nama string `json:"nama" gorm:"type:varchar(100);not null"`
}

type KategoriCreate struct {
	Nama          string    `json:"nama" gorm:"type:varchar(255);not null"`
	Deskripsi     string    `json:"deskripsi" gorm:"type:text;not null"`
	RefKategoriID uuid.UUID `json:"ref_kategori_id" gorm:"type:uuid;not null"`
}

type KategoriReference struct {
	ID          uuid.UUID `json:"id" gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	ReferenceID uuid.UUID `json:"ref_kategori_id" gorm:"type:uuid;not null;index"`
	Nama        string    `json:"nama"`
	Deskripsi   string    `json:"deskripsi"`
}

type Reference struct {
	ID   uuid.UUID `json:"id" gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	Nama string    `json:"nama"`
	// Values []KategoriReference `json:"values"`

	Values []KategoriReference `json:"values" gorm:"foreignKey:ReferenceID;constraint:OnDelete:CASCADE"`
}
