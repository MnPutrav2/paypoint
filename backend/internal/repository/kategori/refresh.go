package kategoriRepo

import (
	"context"
	"kavi-kasir/internal/mapper"
	kategoriModel "kavi-kasir/internal/model/kategori"
)

func (q *kategoriRepository) RefreshReference(ctx context.Context) ([]kategoriModel.Reference, error) {
	var (
		ref []kategoriModel.RefKategori
		m   []kategoriModel.Reference
	)

	if err := q.db.WithContext(ctx).Model(&kategoriModel.RefKategori{}).Find(&ref).Error; err != nil {
		return nil, err
	}

	for _, i := range ref {
		var kat []kategoriModel.Kategori

		if err := q.db.WithContext(ctx).Model(&kategoriModel.Kategori{}).Where("ref_kategori_id = ?", i.ID).Find(&kat).Error; err != nil {
			return nil, err
		}

		x := mapper.MapperReference(kat)
		m = append(m, kategoriModel.Reference{
			ID:     i.ID,
			Nama:   i.Nama,
			Values: x,
		})
	}

	return m, nil
}
