package kategoriRepo

import (
	"context"
	"kavi-kasir/internal/mapper"
	kategoriModel "kavi-kasir/internal/model/kategori"
)

func (q *kategoriRepository) RefreshReferenceAllData(ctx context.Context) ([]kategoriModel.Reference, string, error) {
	var (
		ref     []kategoriModel.RefKategori
		m       []kategoriModel.Reference
		lastref kategoriModel.RefKategori
		lastkat kategoriModel.Kategori
		last    string
	)

	if err := q.db.WithContext(ctx).Model(&kategoriModel.RefKategori{}).Order("updated_at DESC").Limit(1).Find(&lastref).Error; err != nil {
		return nil, "", err
	}

	if err := q.db.WithContext(ctx).Model(&kategoriModel.Kategori{}).Order("updated_at DESC").Limit(1).Find(&lastkat).Error; err != nil {
		return nil, "", err
	}

	if err := q.db.WithContext(ctx).Model(&kategoriModel.RefKategori{}).Find(&ref).Error; err != nil {
		return nil, "", err
	}

	for _, i := range ref {
		var kat []kategoriModel.Kategori

		if err := q.db.WithContext(ctx).Model(&kategoriModel.Kategori{}).Preload("RefKategori").Where("ref_kategori_id = ?", i.ID).Find(&kat).Error; err != nil {
			return nil, "", err
		}

		x := mapper.MapperReference(kat)
		m = append(m, kategoriModel.Reference{
			ID:     i.ID,
			Nama:   i.Nama,
			Values: x,
		})
	}

	if lastkat.UpdatedAt.After(lastref.UpdatedAt) {
		last = lastkat.UpdatedAt.Format("2006-01-02 15:04:05")
	} else {
		last = lastref.UpdatedAt.Format("2006-01-02 15:04:05")
	}

	return m, last, nil
}
