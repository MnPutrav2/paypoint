package kategoriRepo

import (
	"context"
	"kavi-kasir/internal/mapper"
	kategoriModel "kavi-kasir/internal/model/kategori"
	"time"
)

func (q *kategoriRepository) RefreshReferenceData(ctx context.Context, tm time.Time) ([]kategoriModel.Reference, string, error) {
	var (
		ref     []kategoriModel.RefKategori
		m       []kategoriModel.Reference
		lastref kategoriModel.RefKategori
		lastkat kategoriModel.Kategori
		last    string
	)

	loc, _ := time.LoadLocation("Asia/Jakarta")
	t, _ := time.ParseInLocation("2006-01-02 15:04:05", tm.Format("2006-01-02 15:04:05"), loc)

	if err := q.db.WithContext(ctx).Model(&kategoriModel.RefKategori{}).Order("updated_at DESC").Limit(1).Find(&lastref).Error; err != nil {
		return nil, "", err
	}

	if err := q.db.WithContext(ctx).Model(&kategoriModel.Kategori{}).Order("updated_at DESC").Limit(1).Find(&lastkat).Error; err != nil {
		return nil, "", err
	}

	if lastkat.UpdatedAt.After(lastref.UpdatedAt) {
		if lastkat.UpdatedAt.After(t) {
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

			last = lastkat.UpdatedAt.Format("2006-01-02 15:04:05")
		} else if lastkat.UpdatedAt.Equal(t) {
			last = lastkat.UpdatedAt.Format("2006-01-02 15:04:05")
		} else {
			last = lastkat.UpdatedAt.Format("2006-01-02 15:04:05")
		}
	} else {
		if lastref.UpdatedAt.After(t) {
			if err := q.db.WithContext(ctx).Model(&kategoriModel.RefKategori{}).Where("updated_at > ?", tm).Order("updated_at DESC").Find(&ref).Error; err != nil {
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

			last = lastref.UpdatedAt.Format("2006-01-02 15:04:05")
		} else if lastref.UpdatedAt.Equal(t) {
			last = lastref.UpdatedAt.Format("2006-01-02 15:04:05")
		} else {
			last = lastref.UpdatedAt.Format("2006-01-02 15:04:05")
		}
	}

	return m, last, nil
}
