package katalogRepo

import (
	"context"
	katalogModel "kavi-kasir/internal/model/katalog"

	"github.com/google/uuid"
)

func (q *katalogRepository) DeleteKatalog(ctx context.Context, id uuid.UUID, userId uuid.UUID) error {
	if err := q.db.WithContext(ctx).Delete(&katalogModel.Katalog{}, "id = ? AND user_id = ?", id, userId).Error; err != nil {
		return err
	}

	return nil
}
