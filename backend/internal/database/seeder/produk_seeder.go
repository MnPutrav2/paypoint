package seeder

import (
	"encoding/json"
	"os"
	"path/filepath"
	"reflect"
	"strings"

	produkModel "kavi-kasir/internal/model/produk"

	"gorm.io/gorm"
)

type ProdukSeeder struct{}

func (s ProdukSeeder) Name() string {
	return "ProdukSeeder"
}

func (s ProdukSeeder) Run(db *gorm.DB) error {
	seederName := strings.ToLower(s.Name())
	jsonPath := filepath.Join(
		"internal/database/dummy",
		seederName+".json",
	)

	file, err := os.ReadFile(jsonPath)
	if err != nil {
		return err
	}

	var data []produkModel.Produk
	if err := json.Unmarshal(file, &data); err != nil {
		return err
	}

	uniqueField := DetectUniqueField(produkModel.Produk{})

	for _, item := range data {
		if err := db.
			Where(map[string]any{
				uniqueField: reflect.ValueOf(item).FieldByName(uniqueField).Interface(),
			}).
			FirstOrCreate(&item).Error; err != nil {
			return err
		}
	}

	return nil
}
