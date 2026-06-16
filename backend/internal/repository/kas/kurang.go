package kasRepo

import (
	"context"
	kasModel "kavi-kasir/internal/model/kas"
	userModel "kavi-kasir/internal/model/user"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

func (r *kasRepository) Kurang(ctx context.Context, userID uuid.UUID, jumlah int64, keterangan string) error {
	return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		// cek saldo cukup dulu
		var saldo int64
		if err := tx.Model(&userModel.User{}).
			Where("id = ?", userID).
			Select("saldo").
			Scan(&saldo).Error; err != nil {
			return err
		}

		if saldo < jumlah {
			return gorm.ErrInvalidData // ganti dengan custom error jika ada
		}

		if err := tx.Create(&kasModel.Kas{
			UserID:     userID,
			Jumlah:     -jumlah, // negatif = keluar
			Keterangan: keterangan,
		}).Error; err != nil {
			return err
		}

		return tx.Model(&userModel.User{}).
			Where("id = ?", userID).
			UpdateColumn("saldo", gorm.Expr("saldo - ?", jumlah)).Error
	})
}
