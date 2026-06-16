package kategoriRepo

import (
	"context"
	kategoriModel "kavi-kasir/internal/model/kategori"
	"strings"
)

func (q *kategoriRepository) GetAllKategoriPaginated(
	ctx context.Context,
	page,
	size int,
	keyword,
	ref string,
) ([]kategoriModel.Kategori, int, error) {

	var (
		kategori []kategoriModel.Kategori
		total    int64
	)

	query := q.db.
		WithContext(ctx).
		Model(&kategoriModel.Kategori{}).
		Joins("LEFT JOIN ref_kategoris ON ref_kategoris.id = kategoris.ref_kategori_id")

	if keyword != "" {
		query = query.Where(
			"kategoris.nama ILIKE ?",
			"%"+keyword+"%",
		)
	}

	ref = strings.TrimSpace(ref)

	if ref != "" {
		query = query.Where(
			"LOWER(ref_kategoris.nama) = LOWER(?)",
			ref,
		)
	}

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * size

	if err := query.
		Preload("RefKategori").
		Limit(size).
		Offset(offset).
		Find(&kategori).Error; err != nil {
		return nil, 0, err
	}

	return kategori, int(total), nil
}
