package kasRepo

import (
	"context"
	kasModel "kavi-kasir/internal/model/kas"
	userModel "kavi-kasir/internal/model/user"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Setiap transaksi masuk/keluar kas
func (r *kasRepository) Tambah(ctx context.Context, userID uuid.UUID, jumlah int64, keterangan string) error {
	return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		// 1. catat di tabel kas
		if err := tx.Create(&kasModel.Kas{
			UserID:     userID,
			Jumlah:     jumlah,
			Keterangan: keterangan,
		}).Error; err != nil {
			return err
		}

		// 2. update saldo di user — atomic, tidak bisa setengah-setengah
		if err := tx.Model(&userModel.User{}).
			Where("id = ?", userID).
			UpdateColumn("saldo", gorm.Expr("saldo + ?", jumlah)).Error; err != nil {
			return err
		}

		return nil
	})
}
