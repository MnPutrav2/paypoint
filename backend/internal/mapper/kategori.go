package mapper

import (
	"kavi-kasir/internal/model"
	kategoriModel "kavi-kasir/internal/model/kategori"

	"github.com/google/uuid"
)

func MapperCreateKategori(req kategoriModel.KategoriCreate) kategoriModel.Kategori {
	return kategoriModel.Kategori{
		Nama:          req.Nama,
		Deskripsi:     req.Deskripsi,
		RefKategoriID: req.RefKategoriID,
	}
}

func MapperCreateRefKategori(req kategoriModel.RefKategoriCreate) kategoriModel.RefKategori {
	return kategoriModel.RefKategori{
		Nama: req.Nama,
	}
}

func MapperKategoriShowPagination(req []kategoriModel.Kategori) []kategoriModel.KategoriShow {
	ma := make([]kategoriModel.KategoriShow, 0, len(req))

	for _, v := range req {
		ma = append(ma, kategoriModel.KategoriShow{
			ID:        v.ID,
			Nama:      v.Nama,
			Deskripsi: v.Deskripsi,
			RefKategori: kategoriModel.RefKategoriShow{
				Nama: v.RefKategori.Nama,
				ID:   v.RefKategori.ID,
			},
		})
	}

	return ma
}

func MapperKategoriShow(v kategoriModel.Kategori) kategoriModel.KategoriShow {
	return kategoriModel.KategoriShow{
		ID:        v.ID,
		Nama:      v.Nama,
		Deskripsi: v.Deskripsi,
		RefKategori: kategoriModel.RefKategoriShow{
			Nama: v.RefKategori.Nama,
			ID:   v.RefKategori.ID,
		},
	}
}

func MapperRefKategoriShowPagination(req []kategoriModel.RefKategori) []kategoriModel.RefKategoriShow {
	ma := make([]kategoriModel.RefKategoriShow, 0, len(req))

	for _, v := range req {
		ma = append(ma, kategoriModel.RefKategoriShow{
			ID:   v.ID,
			Nama: v.Nama,
		})
	}

	return ma
}

func MapperReference(req []kategoriModel.Kategori) []kategoriModel.KategoriReference {
	ma := make([]kategoriModel.KategoriReference, 0, len(req))

	for _, v := range req {
		ma = append(ma, kategoriModel.KategoriReference{
			ID:        v.ID,
			Nama:      v.Nama,
			Deskripsi: v.Deskripsi,
		})
	}

	return ma
}

func MappingRefKategoriUpdateKey(req kategoriModel.RefKategoriCreate, id uuid.UUID) []model.UpdateKey {
	return []model.UpdateKey{
		{
			Key:   "id",
			Value: id,
		},
		{
			Key:   "nama",
			Value: req.Nama,
		},
	}
}
