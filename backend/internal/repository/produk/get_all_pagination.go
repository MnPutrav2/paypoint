package produkRepo

import (
	"context"
	"kavi-kasir/internal/model/entity"
	produkModel "kavi-kasir/internal/model/produk"
	jwtEnc "kavi-kasir/pkg/auth/jwt"
	util "kavi-kasir/pkg/util/const"
)

func (repo *produkRepository) GetAllProdukPaginated(ctx context.Context, page, size int, keyword string) ([]entity.ProdukWithKatalog, int, error) {
	var (
		result []entity.ProdukWithKatalog
		total  int64
	)

	userID := ctx.Value(util.ContextUserID).(*jwtEnc.Claims).UserID
	q := repo.db.WithContext(ctx).Model(&produkModel.Produk{}).
		Select(`
    produks.id,
    produks.nama,
    produks.detail,
    produks.foto,
    produks.harga,
    produks.terjual,

    katalogs.id AS katalog_id,
    COALESCE(katalogs.harga, 0) AS harga_jual,

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
		Joins(`
		    LEFT JOIN katalogs
		        ON katalogs.produk_id = produks.id
		        AND katalogs.user_id = ?
		`, userID).
		Joins("JOIN kategoris ON produks.kategori_id = kategoris.id").
		Joins("JOIN ref_kategoris ON kategoris.ref_kategori_id = ref_kategoris.id").
		Where("is_deleted = false")
	if keyword != "" {
		q = q.Where("produks.nama ILIKE ?", "%"+keyword+"%")
	}
	if err := q.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	if err := q.
		Limit(size).
		Offset(page).
		Scan(&result).Error; err != nil {
		return nil, 0, err
	}

	return result, int(total), nil
}
