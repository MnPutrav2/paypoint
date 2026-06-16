package katalogRepo

import (
	"context"
	katalogModel "kavi-kasir/internal/model/katalog"
)

func (q *katalogRepository) CreateKatalog(ctx context.Context, req *katalogModel.Katalog) (katalogModel.Katalog, error) {
	if err := q.db.WithContext(ctx).Create(&req).Error; err != nil {
		return katalogModel.Katalog{}, err
	}

	var katalog katalogModel.Katalog
	if err := q.db.WithContext(ctx).Model(&katalogModel.Katalog{}).Preload("Produk.Kategori.RefKategori").Where("id = ?", req.ID).Find(&katalog).Error; err != nil {
		return katalogModel.Katalog{}, err
	}

	return katalog, nil
}
