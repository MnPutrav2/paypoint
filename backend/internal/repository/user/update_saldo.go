package userRepo

import (
	"context"
	"errors"
	userModel "kavi-kasir/internal/model/user"
	utilConst "kavi-kasir/pkg/util/const"

	"github.com/google/uuid"
)

// repository
func (r *userRepository) UpdateSaldo(ctx context.Context, userID uuid.UUID, saldo int64, tipe utilConst.UPDATE_SALDO_TYPE) error {
	user, err := r.GetUserById(ctx, userID)
	if err != nil {
		return err
	}

	var newSaldo int64
	switch tipe {
	case utilConst.UpdateSaldoTambah:
		newSaldo = user.Saldo + saldo
	case utilConst.UpdateSaldoKurang:
		if user.Saldo < saldo {
			return errors.New("saldo tidak cukup")
		}
		newSaldo = user.Saldo - saldo
	default:
		return errors.New("tipe update tidak valid")
	}

	if err := r.db.WithContext(ctx).
		Model(&userModel.User{}).
		Where("id = ?", userID).
		Update("saldo", newSaldo).Error; err != nil {
		return err
	}

	return nil
}
