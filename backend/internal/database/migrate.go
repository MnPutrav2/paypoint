package database

import (
	authModel "kavi-kasir/internal/model/auth"
	bankModel "kavi-kasir/internal/model/bank"
	katalogModel "kavi-kasir/internal/model/katalog"
	kategoriModel "kavi-kasir/internal/model/kategori"
	orderModel "kavi-kasir/internal/model/order"
	produkModel "kavi-kasir/internal/model/produk"
	rekeningModel "kavi-kasir/internal/model/rekening"
	stokModel "kavi-kasir/internal/model/stok"
	userModel "kavi-kasir/internal/model/user"

	"gorm.io/gorm"
)

func Migrate(db *gorm.DB) error {
	return db.AutoMigrate(
		&kategoriModel.RefKategori{},
		&kategoriModel.Kategori{},
		&produkModel.Produk{},
		&stokModel.Stok{},
		&orderModel.Order{},
		&orderModel.OrderItem{},
		&orderModel.OrderPay{},
		&userModel.User{},
		&authModel.AccessToken{},
		&authModel.RefreshToken{},
		&katalogModel.Katalog{},
		&bankModel.Bank{},
		&rekeningModel.Rekening{},
	)
}
