package seeder

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path/filepath"

	kategoriModel "kavi-kasir/internal/model/kategori"
	"kavi-kasir/pkg/util"

	"gorm.io/gorm"
)

type RefSeeder struct{}

func (s RefSeeder) Name() string {
	return "RefSeeder"
}

func (s RefSeeder) Model() interface{} {
	return &kategoriModel.RefSeed{}
}

func (s RefSeeder) Run(db *gorm.DB) error {
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

	var data []kategoriModel.RefSeed
	if err := json.Unmarshal(file, &data); err != nil {
		return err
	}

	for _, item := range data {

		// 🔥 cek atau buat parent reference
		ref := kategoriModel.RefKategori{
			Nama: item.Nama,
		}

		tx := db.Where(kategoriModel.RefKategori{
			Nama: item.Nama,
		}).FirstOrCreate(&ref)
		if tx.Error != nil {
			log.Fatal(tx.Error)
		}
		// 🔥 insert children (values)
		for _, val := range item.Values {
			child := kategoriModel.Kategori{
				RefKategoriID: ref.ID,
				Nama:          val.Nama,
				Deskripsi:     val.Deskripsi,
			}

			tx := db.Where(kategoriModel.Kategori{
				RefKategoriID: ref.ID,
				Nama:          val.Nama,
			}).FirstOrCreate(&child)
			if tx.Error != nil {
				log.Fatal(tx.Error)
			}
		}
	}

	return nil
}
