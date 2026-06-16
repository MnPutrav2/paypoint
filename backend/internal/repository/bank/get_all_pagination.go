package bankRepo

import (
	"context"
	bankModel "kavi-kasir/internal/model/bank"
)

func (q *bankRepository) GetAllPagination(ctx context.Context, page, size int, keyword string) ([]bankModel.Bank, int, error) {
	var (
		bank  []bankModel.Bank
		total int64
	)

	if err := q.db.WithContext(ctx).Model(&bankModel.Bank{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}
	// offset := (page - 1) * size
	query := q.db.WithContext(ctx).Model(&bankModel.Bank{})

	if keyword != "" {
		query = query.Where("nama ILIKE ?", "%"+keyword+"%")
	}

	// offset := (page - 1) * size

	if err := query.
		Limit(size).
		Offset(page).
		Find(&bank).Error; err != nil {
		return nil, 0, err
	}

	return bank, int(total), nil
}
