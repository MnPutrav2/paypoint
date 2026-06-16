package katalogRepo

import (
	"context"
	katalogModel "kavi-kasir/internal/model/katalog"
	jwtEnc "kavi-kasir/pkg/auth/jwt"
	util "kavi-kasir/pkg/util/const"
)

func (repo *katalogRepository) GetAllKatalogPagination(ctx context.Context, page, size int, keyword string) ([]katalogModel.Katalog, int, error) {
	var (
		katalog []katalogModel.Katalog
		total   int64
	)
	userID := ctx.Value(util.ContextUserID).(*jwtEnc.Claims).UserID

	q := repo.db.WithContext(ctx).
		Model(&katalogModel.Katalog{}).
		Joins("Produk").
		Preload("Produk.Kategori.RefKategori").
		Where("user_id = ?", userID)

	if keyword != "" {
		q = q.Where("produks.nama ILIKE ?", "%"+keyword+"%")
	}
	if err := q.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	if err := q.Limit(size).Offset(page).Find(&katalog).Error; err != nil {
		return nil, 0, err
	}

	return katalog, int(total), nil
}
