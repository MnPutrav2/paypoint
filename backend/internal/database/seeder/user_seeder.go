package seeder

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"

	kategoriModel "kavi-kasir/internal/model/kategori"
	userModel "kavi-kasir/internal/model/user"
	authService "kavi-kasir/internal/service/auth"
	"kavi-kasir/pkg/util"

	"gorm.io/gorm"
)

type UserSeeder struct {
	Service authService.AuthService
}

func (s UserSeeder) Name() string {
	return "UserSeeder"
}

func (s UserSeeder) Model() interface{} {
	return &userModel.UserSeed{}
}

func (s UserSeeder) Run(db *gorm.DB) error {

	fmt.Printf("Cek: %s", s.Name())
	fmt.Println("=====================")
	seederName := util.SnakeCase(s.Name())
	jsonPath := filepath.Join(
		"internal/database/dummy",
		seederName+".json",
	)

	file, err := os.ReadFile(jsonPath)
	if err != nil {
		return err
	}

	var data []userModel.UserSeed
	if err := json.Unmarshal(file, &data); err != nil {
		return err
	}
	for _, item := range data {

		// 🔥 1. Cek apakah user sudah ada (tanpa First)
		var count int64
		if err := db.
			Model(&userModel.User{}).
			Where("email = ? OR username = ?", item.Email, item.Username).
			Count(&count).Error; err != nil {
			return err
		}

		if count > 0 {
			continue // user sudah ada → skip
		}

		// 🔥 2. Cari role / kategori berdasarkan nama
		var kategori kategoriModel.Kategori
		if err := db.
			Where("nama = ?", item.Role).
			First(&kategori).Error; err != nil {
			return fmt.Errorf("role '%s' tidak ditemukan", item.Role)
		}

		// 🔥 3. Buat user (password masih plain, nanti di-hash service)
		user := userModel.User{
			Username:   item.Username,
			Nama:       item.Nama,
			Email:      item.Email,
			Password:   item.Password,
			NoTelp:     item.NoTelp,
			KategoriID: kategori.ID,
		}

		// 🔥 4. Pakai service supaya password ke-hash
		if _, err := s.Service.CreateAccountService(&user); err != nil {
			return err
		}
	}

	return nil
}
