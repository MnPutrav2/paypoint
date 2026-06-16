package seeder

import (
	"encoding/json"
	"fmt"
	"os"
	"reflect"
	"strings"
)

func DetectUniqueField(model any) string {
	t := reflect.TypeOf(model)

	if t.Kind() == reflect.Pointer {
		t = t.Elem()
	}

	for i := 0; i < t.NumField(); i++ {
		field := t.Field(i)
		tag := field.Tag.Get("gorm")

		if tag == "" {
			continue
		}

		if contains(tag, "unique") {
			return field.Name
		}
	}

	return "ID" // fallback
}

func contains(tag, keyword string) bool {
	return len(tag) > 0 && (tag == keyword || stringContains(tag, keyword))
}

func stringContains(s, sub string) bool {
	return len(s) >= len(sub) && (len(sub) > 0 && (len(s) > 0 && (stringIndex(s, sub) >= 0)))
}

func stringIndex(s, sub string) int {
	for i := 0; i+len(sub) <= len(s); i++ {
		if s[i:i+len(sub)] == sub {
			return i
		}
	}
	return -1
}

func GenerateJSONFromModel(model any) ([]byte, error) {
	t := reflect.TypeOf(model)
	if t.Kind() == reflect.Pointer {
		t = t.Elem()
	}

	item := make(map[string]any)

	for i := 0; i < t.NumField(); i++ {
		field := t.Field(i)

		// skip gorm.Model
		if field.Anonymous {
			continue
		}

		jsonKey := field.Tag.Get("json")
		if jsonKey == "" || jsonKey == "-" {
			jsonKey = strings.ToLower(field.Name)
		}

		item[jsonKey] = ExampleValue(field.Type)
	}

	return json.MarshalIndent([]any{item}, "", "  ")
}

func ExampleValue(t reflect.Type) any {
	switch t.Kind() {
	case reflect.String:
		return "example"
	case reflect.Int, reflect.Int64:
		return 1
	case reflect.Uint:
		return 1
	case reflect.Bool:
		return true
	default:
		return nil
	}
}

func InjectSeeder(seederName string) {
	path := "cmd/seed.go"
	content, _ := os.ReadFile(path)

	line := fmt.Sprintf("\t\tseeder.%s{},\n", seederName)

	if strings.Contains(string(content), line) {
		return
	}

	newContent := strings.Replace(
		string(content),
		"seedersList := []seeder.Seeder{\n",
		"seedersList := []seeder.Seeder{\n"+line,
		1,
	)

	_ = os.WriteFile(path, []byte(newContent), 0o644)
}
