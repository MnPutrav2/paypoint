package katalogRepo

import (
	"context"
	katalogModel "kavi-kasir/internal/model/katalog"

	"github.com/google/uuid"
)

func (q *katalogRepository) UpdateKatalog(ctx context.Context, id uuid.UUID, harga int) (katalogModel.Katalog, error) {
	if err := q.db.WithContext(ctx).Model(&katalogModel.Katalog{}).Where("id = ?", id).Update("harga", harga).Error; err != nil {
		return katalogModel.Katalog{}, err
	}

	var katalog katalogModel.Katalog
	if err := q.db.WithContext(ctx).Model(&katalogModel.Katalog{}).Preload("Produk.Kategori.RefKategori").Where("id = ?", id).Find(&katalog).Error; err != nil {
		return katalogModel.Katalog{}, err
	}

	return katalog, nil
}
