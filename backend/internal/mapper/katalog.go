package mapper

import (
	katalogModel "kavi-kasir/internal/model/katalog"
	kategoriModel "kavi-kasir/internal/model/kategori"
	produkModel "kavi-kasir/internal/model/produk"

	"github.com/google/uuid"
)

func MappingKatalogCreate(req katalogModel.KatalogCreateRequest, uid uuid.UUID) katalogModel.Katalog {
	return katalogModel.Katalog{
		UserID:   uid,
		ProdukID: req.ProdukID,
		Harga:    req.Harga,
	}
}

func MappingKatalogAll(req []katalogModel.Katalog) []katalogModel.KatalogShow {
	ma := make([]katalogModel.KatalogShow, 0, len(req))

	for _, v := range req {
		ma = append(ma, katalogModel.KatalogShow{
			ID: v.ID,
			Produk: produkModel.ProdukShow{
				ID:     v.Produk.ID,
				Nama:   v.Produk.Nama,
				Detail: v.Produk.Detail,
				Foto:   v.Produk.Foto,
				Harga:  v.Produk.Harga,
				Kategori: &kategoriModel.KategoriShow{
					ID:        v.Produk.Kategori.ID,
					Nama:      v.Produk.Kategori.Nama,
					Deskripsi: v.Produk.Kategori.Deskripsi,
					RefKategori: kategoriModel.RefKategoriShow{
						ID:   v.Produk.Kategori.RefKategori.ID,
						Nama: v.Produk.Kategori.RefKategori.Nama,
					},
				},
			},
			HargaKatalog: v.Harga,
		})
	}

	return ma
}

func MappingKatalog(v katalogModel.Katalog) katalogModel.KatalogShow {
	return katalogModel.KatalogShow{
		ID: v.ID,
		Produk: produkModel.ProdukShow{
			ID:     v.Produk.ID,
			Nama:   v.Produk.Nama,
			Detail: v.Produk.Detail,
			Foto:   v.Produk.Foto,
			Harga:  v.Produk.Harga,
			Kategori: &kategoriModel.KategoriShow{
				ID:        v.Produk.Kategori.ID,
				Nama:      v.Produk.Kategori.Nama,
				Deskripsi: v.Produk.Kategori.Deskripsi,
				RefKategori: kategoriModel.RefKategoriShow{
					ID:   v.Produk.Kategori.RefKategori.ID,
					Nama: v.Produk.Kategori.RefKategori.Nama,
				},
			},
		},
		HargaKatalog: v.Harga,
	}
}
