package make

import (
	"fmt"
	"kavi-kasir/internal/database/registry"
	"kavi-kasir/internal/database/seeder"
	"os"
	"path/filepath"
	"strings"
)

func Seeder(name string) {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run ./cmd/make/seed UserSeeder")
		return
	}

	// UserSeeder → user_seeder
	slug := strings.ToLower(
		strings.TrimSuffix(name, "Seeder"),
	) + "_seeder"

	// paths
	seederDir := "internal/database/seeder"
	jsonDir := "internal/database/dummy"

	seederPath := filepath.Join(seederDir, slug+".go")
	jsonPath := filepath.Join(jsonDir, slug+".json")

	_ = os.MkdirAll(seederDir, 0o755)
	_ = os.MkdirAll(jsonDir, 0o755)

	// prevent overwrite
	if _, err := os.Stat(seederPath); err == nil {
		fmt.Println("❌ Seeder already exists:", seederPath)
		return
	}

	nameTrim := name + "Seeder"
	nameLower := strings.ToLower(name)
	model, ok := registry.Models[name]
	if !ok {
		panic("model not registered: " + name)
	}

	jsonData, err := seeder.GenerateJSONFromModel(model)
	if err != nil {
		panic(err)
	}

	_ = os.WriteFile(jsonPath, jsonData, 0o644)

	seederTemplate := fmt.Sprintf(`package seeder

import (
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"reflect"

	"kavi-kasir/internal/model/%s"
	"gorm.io/gorm"
)

type %s struct{}

func (s %s) Name() string {
	return "%s"
}

func (s %s) Run(db *gorm.DB) error {
	seederName := strings.ToLower(s.Name())
	jsonPath := filepath.Join(
		"internal/database/dummy",
		seederName+".json",
	)

	file, err := os.ReadFile(jsonPath)
	if err != nil {
		return err
	}

	var data []%sModel.%s
	if err := json.Unmarshal(file, &data); err != nil {
		return err
	}

	uniqueField := DetectUniqueField(%sModel.%s{})

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
`, nameLower, nameTrim, nameTrim, nameTrim, nameTrim, nameLower, name, nameLower, name)

	_ = os.WriteFile(seederPath, []byte(seederTemplate), 0o644)
	seeder.InjectSeeder(nameTrim)

	fmt.Println("✅ Seeder created:", seederPath)
	fmt.Println("✅ JSON dummy created:", jsonPath)
	fmt.Println("✅ Seeder Injected:", nameTrim)
}
