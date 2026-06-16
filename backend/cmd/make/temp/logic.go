package temp

import (
	"bufio"
	"os"
	"path/filepath"
	"strings"
)

func capitalize(word string) string {
	if len(word) == 0 {
		return word
	}
	return strings.ToUpper(word[:1]) + word[1:]
}

func process(template, path, dir, name string) string {
	file := name + ".go"

	os.MkdirAll("internal/"+path+dir, 0o755)
	handlePath := "internal/" + path + dir
	save := filepath.Join(handlePath, file)

	os.WriteFile(save, []byte(template), 0o644)
	return "Created:" + save
}

func moduleReader() string {
	file, err := os.Open("go.mod")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())

		if strings.HasPrefix(line, "module ") {
			moduleName := strings.TrimSpace(strings.TrimPrefix(line, "module"))
			return moduleName
		}
	}

	return ""
}
