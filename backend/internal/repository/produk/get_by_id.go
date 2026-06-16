package produkRepo

import (
	"context"
	"kavi-kasir/internal/model/entity"
	produkModel "kavi-kasir/internal/model/produk"

	"github.com/google/uuid"
)

func (q *produkRepository) GetProdukByIDProduk(ctx context.Context, id uuid.UUID) (entity.ProdukWithKatalog, error) {
	var produk entity.ProdukWithKatalog

	if err := q.db.WithContext(ctx).Model(&produkModel.Produk{}).
		Select(`
		produks.id,
		produks.nama,
		produks.detail,
		produks.foto,
		produks.harga,
		produks.terjual,
		kategoris.id        AS kategori__id,
		kategoris.nama      AS kategori__nama,
		kategoris.deskripsi AS kategori__deskripsi,
		ref_kategoris.id    AS kategori__ref_kategori__id,
		ref_kategoris.nama  AS kategori__ref_kategori__nama,
		CASE
			WHEN katalogs.id IS NOT NULL THEN true
			ELSE false
		END AS katalog
	`).
		Joins("LEFT JOIN katalogs ON katalogs.produk_id = produks.id").
		Joins("JOIN kategoris ON produks.kategori_id = kategoris.id").
		Joins("JOIN ref_kategoris ON kategoris.ref_kategori_id = ref_kategoris.id").Where("is_deleted = false AND produks.id = ?", id).Scan(&produk).Error; err != nil {
		return entity.ProdukWithKatalog{}, err
	}

	return produk, nil
}
