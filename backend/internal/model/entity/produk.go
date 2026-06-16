package entity

import (
	"github.com/google/uuid"
)

type ProdukWithKatalog struct {
	ID        uuid.UUID   `json:"id"`
	Nama      string      `json:"nama"`
	Detail    string      `json:"detail"`
	Foto      string      `json:"foto"`
	Harga     int         `json:"harga"`
	Kategori  KategoriDTO `json:"kategori" gorm:"embedded;embeddedPrefix:kategori__"`
	Katalog   bool        `json:"katalog"`
	KatalogId uuid.UUID   `json:"katalogId" gorm:"column:katalog_id"`
	HargaJual int         `json:"hargaJual" gorm:"column:harga_jual"`
	Terjual   int         `json:"terjual"`
}

type KategoriDTO struct {
	ID          uuid.UUID      `json:"id"`
	Nama        string         `json:"nama"`
	Deskripsi   string         `json:"deskripsi"`
	RefKategori RefKategoriDTO `json:"ref_kategori" gorm:"embedded;embeddedPrefix:ref_kategori__"`
}

type RefKategoriDTO struct {
	ID   uuid.UUID `json:"id"`
	Nama string    `json:"nama"`
}
