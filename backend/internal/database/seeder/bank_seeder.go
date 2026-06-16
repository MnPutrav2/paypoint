package seeder

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"reflect"

	bankModel "kavi-kasir/internal/model/bank"
	"kavi-kasir/pkg/util"

	"gorm.io/gorm"
)

type BankSeeder struct{}

func (s BankSeeder) Name() string {
	return "BankSeeder"
}
func (s BankSeeder) Model() interface{} {
	return &bankModel.Bank{}
}

func (s BankSeeder) Run(db *gorm.DB) error {
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

	var data []bankModel.Bank
	if err := json.Unmarshal(file, &data); err != nil {
		return err
	}

	uniqueField := DetectUniqueField(bankModel.Bank{})

	for _, item := range data {

		stmt := &gorm.Statement{DB: db}
		if err := stmt.Parse(&item); err != nil {
			return err
		}

		field := stmt.Schema.LookUpField(uniqueField)
		if field == nil {
			return fmt.Errorf("field %s not found in schema", uniqueField)
		}

		columnName := field.DBName
		value := reflect.ValueOf(item).FieldByName(uniqueField).Interface()

		if err := db.
			Where(columnName+" = ?", value).
			FirstOrCreate(&item).Error; err != nil {
			return err
		}
	}

	return nil
}
