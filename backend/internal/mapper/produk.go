package mapper

import (
	"fmt"
	"kavi-kasir/internal/model"
	"kavi-kasir/internal/model/entity"
	kategoriModel "kavi-kasir/internal/model/kategori"
	produkModel "kavi-kasir/internal/model/produk"
	"kavi-kasir/pkg/minio"
	"net/url"
)

func MappingPatchProduk(req produkModel.ProdukPatch) map[string]any {
	data := map[string]any{}

	fmt.Println()

	if req.Nama != nil {
		data["nama"] = *req.Nama
	}

	if req.Detail != nil {
		data["detail"] = *req.Detail
	}

	if req.Foto != nil {
		data["foto"] = *req.Foto
	}

	if req.Harga != nil {
		data["harga"] = *req.Harga
	}

	if req.KategoriID != nil {
		data["kategori_id"] = *req.KategoriID
	}

	return data
}

func MappingCreateProduk(req produkModel.Produk) produkModel.Produk {
	return produkModel.Produk{
		Nama:       req.Nama,
		Detail:     req.Detail,
		Foto:       req.Foto,
		Harga:      req.Harga,
		KategoriID: req.KategoriID,
	}
}

func MappingSingleProduk(req *produkModel.Produk) produkModel.ProdukShow {
	reqParams := make(url.Values)
	reqParams.Set("response-content-disposition", "inline")
	// presignedURL, _ := minio.NewMinio().PresignedGetObject(context.Background(), os.Getenv("MINIO_BUCKET"), req.Foto, time.Minute*10, reqParams)

	return produkModel.ProdukShow{
		ID:      req.ID,
		Nama:    req.Nama,
		Detail:  req.Detail,
		Foto:    minio.GetPublicURL(req.Foto),
		Harga:   req.Harga,
		Terjual: req.Terjual,
		Kategori: &kategoriModel.KategoriShow{
			ID:        req.Kategori.ID,
			Nama:      req.Kategori.Nama,
			Deskripsi: req.Kategori.Deskripsi,
			RefKategori: kategoriModel.RefKategoriShow{
				ID:   req.Kategori.RefKategori.ID,
				Nama: req.Kategori.RefKategori.Nama,
			},
		},
	}
}

func MappingSliceProduk(req []produkModel.Produk) []produkModel.ProdukShow {
	ma := make([]produkModel.ProdukShow, 0, len(req))
	reqParams := make(url.Values)
	reqParams.Set("response-content-disposition", "inline")

	for _, v := range req {

		ma = append(ma, produkModel.ProdukShow{
			ID:      v.ID,
			Nama:    v.Nama,
			Detail:  v.Detail,
			Foto:    minio.GetPublicURL(v.Foto),
			Harga:   v.Harga,
			Terjual: v.Terjual,
			Kategori: &kategoriModel.KategoriShow{
				ID:        v.Kategori.ID,
				Nama:      v.Kategori.Nama,
				Deskripsi: v.Kategori.Deskripsi,
				RefKategori: kategoriModel.RefKategoriShow{
					ID:   v.Kategori.RefKategori.ID,
					Nama: v.Kategori.RefKategori.Nama,
				},
			},
		})
	}

	return ma
}

func MappingUpdateKey(req map[string]any, res produkModel.Produk) []model.UpdateKey {
	ma := make([]model.UpdateKey, 0, len(req))
	for key, value := range req {
		if key == "kategori_id" {
			ma = append(ma, model.UpdateKey{
				Key:   key,
				Value: res.Kategori,
			})
		} else {
			ma = append(ma, model.UpdateKey{
				Key:   key,
				Value: value,
			})
		}

	}

	return ma
}

func MappingUpdateKeyStruct(req produkModel.ProdukUpdate) []model.UpdateKey {
	return []model.UpdateKey{
		{
			Key:   "nama",
			Value: req.Nama,
		},
		{
			Key:   "detail",
			Value: req.Detail,
		},
		{
			Key:   "foto",
			Value: req.Foto,
		},
		{
			Key:   "harga",
			Value: req.Harga,
		},
		{
			Key:   "kategori_id",
			Value: req.KategoriID,
		},
	}
}

func MappingSliceProdukSigned(req []entity.ProdukWithKatalog) []entity.ProdukWithKatalog {
	ma := make([]entity.ProdukWithKatalog, 0, len(req))
	// reqParams := make(url.Values)
	// reqParams.Set("response-content-disposition", "inline")

	for _, v := range req {
		// presignedURL, _ := minio.NewMinio().PresignedGetObject(context.Background(), os.Getenv("MINIO_BUCKET"), v.Foto, time.Minute*10, reqParams)

		// v.Foto = presignedURL.String()
		v.Foto = minio.GetPublicURL(v.Foto)
		ma = append(ma, v)
	}

	return ma
}
