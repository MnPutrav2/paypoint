package registry

import (
	kategoriModel "kavi-kasir/internal/model/kategori"
	produkModel "kavi-kasir/internal/model/produk"
)

var Models = map[string]any{
	"Produk":   produkModel.Produk{},
	"Kategori": kategoriModel.Kategori{},
}
