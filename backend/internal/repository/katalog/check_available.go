package katalogRepo

import (
	"context"
	katalogModel "kavi-kasir/internal/model/katalog"
	jwtEnc "kavi-kasir/pkg/auth/jwt"
	util "kavi-kasir/pkg/util/const"

	"github.com/google/uuid"
)

func (q *katalogRepository) GetAvailableKatalog(ctx context.Context, id uuid.UUID) bool {
	var i int64
	userID := ctx.Value(util.ContextUserID).(*jwtEnc.Claims).UserID
	if err := q.db.WithContext(ctx).Model(&katalogModel.Katalog{}).
		Where("produk_id = ?", id).
		Where("user_id = ?", userID).
		Count(&i).Error; err != nil {
		return false
	}

	if i >= 1 {
		return true
	}

	return false
}
