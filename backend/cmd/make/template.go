package make

import (
	"bufio"
	"fmt"
	"kavi-kasir/cmd/make/temp"
	"os"
	"path/filepath"
	"strings"
)

func Template(dir, name, ty string) {
	module := moduleReader()

	// This handler template
	hdlTemp := fmt.Sprintf(`
package handler

import (
	"%s/pkg/middleware"
	"%s/pkg/response"
	"database/sql"
	"net/http"
)

// this handler is for URLs that do not have a prefix parameter
// example without prefix -> api/%s
func %sHandler(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		switch r.Method {
		case http.MethodGet:
			handler(func(w http.ResponseWriter, r *http.Request) {
				// Write code in here
			})
		case http.MethodPost:
			handler(func(w http.ResponseWriter, r *http.Request) {
				// Write code in here
			})
		default:
			response.ResponseMessage("method not allowed", "method not allowed", "INFO", 405, w, r)
		}

	}
}

// example with prefix -> api/%s/{id}
func %sHandlerPrefix(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		switch r.Method {
		case http.MethodGet:
			handler(func(w http.ResponseWriter, r *http.Request) {
				// Write code in here
			})
		case http.MethodPut:
			handler(func(w http.ResponseWriter, r *http.Request) {
				// Write code in here
			})
		case http.MethodDelete:
			handler(func(w http.ResponseWriter, r *http.Request) {
				// Write code in here
			})
		default:
			response.ResponseMessage("method not allowed", "method not allowed", "INFO", 405, w, r)
		}

	}
}

// Custom your handler
func handler(next http.HandlerFunc) http.HandlerFunc {
	return middleware.CORS(
		middleware.RateLimiter(1, 1, func(w http.ResponseWriter, r *http.Request) {
			// add more middleware in here
			next(w, r)
		}),
	)
}
`, module, module, name, capitalize(name), name, capitalize(name))

	// this service template
	servTemp := fmt.Sprintf(`
package service

import (
	"database/sql"
)

type %sService struct {
	db *sql.DB
}

type %sService interface {
	// Add function in here
	ExampleService(id string) (string, error)
}

func New%sService(db *sql.DB) %sService {
	return &%sService{db}
}

// Write code in here
func (q *%sService) ExampleService(id string) (string, error) {
	return "success", nil
}
`, name, capitalize(name), capitalize(name), capitalize(name), name, name)

	// this repository template
	switch ty {
	case "-h", "handler":
		handleTemp := process(hdlTemp, "handler", dir, name)
		fmt.Println(handleTemp)
		return
	case "-s", "service":
		serviceTemp := process(servTemp, "service", dir, name)
		fmt.Println(serviceTemp)
		return
	case "-m", "model":
		temp.TemplateModel(name, dir)
		return
	case "-r", "repository":
		temp.TemplateRepo(name, dir)
		temp.TemplateQuery(name, dir)
		return
	case "-a", "all":
		handleTemp := process(hdlTemp, "handler", dir, name)
		serviceTemp := process(servTemp, "service", dir, name)
		temp.TemplateModel(name, dir)
		temp.TemplateRepo(name, dir)
		temp.TemplateQuery(name, dir)
		fmt.Println(handleTemp)
		fmt.Println(serviceTemp)
		return
	case "-q", "query":
		temp.TemplateQuery(name, dir)
		temp.TemplateRepo(name, dir)
	default:
		fmt.Println("invalid command")
		return
	}

}

func process(template, path, dir, name string) string {
	file := name + ".go"

	os.MkdirAll("internal/"+path+dir, 0o755)
	handlePath := "internal/" + path + dir
	save := filepath.Join(handlePath, file)

	os.WriteFile(save, []byte(template), 0o644)
	return "✅Created:" + save
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

func capitalize(word string) string {
	if len(word) == 0 {
		return word
	}
	return strings.ToUpper(word[:1]) + word[1:]
}
