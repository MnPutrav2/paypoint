package kasRepo

import (
	"context"
	kasModel "kavi-kasir/internal/model/kas"

	"github.com/google/uuid"
)

func (r *kasRepository) GetRiwayat(ctx context.Context, userID uuid.UUID) ([]kasModel.Kas, error) {
	var result []kasModel.Kas
	err := r.db.WithContext(ctx).
		Where("user_id = ?", userID).
		Order("created_at DESC").
		Find(&result).Error
	return result, err
}
