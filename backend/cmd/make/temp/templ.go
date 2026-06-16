package temp

import (
	"fmt"
)

func TemplateQuery(name, dir string) {
	query := fmt.Sprintf(
		`package %srepo

const (
	queryGet%sCount           = "SELECT COUNT(*) FROM table_name WHERE name ILIKE $1"
	queryGet%sWithPagination  = "SELECT * WHERE name ILIKE $1 LIMIT $2 OFFSET $3"
	queryGet%sById = "SELECT * FROM table_name WHERE id = $1"
	queryInsert%s             = "INSERT INTO table_name (*) VALUES ($1)"
	queryDelete%s             = "DELETE FROM table_name WHERE id = $1"
)
`, name, capitalize(name), capitalize(name), capitalize(name), capitalize(name), capitalize(name))

	handleQuery := process(query, "repository/", dir+"_repo", "query")
	fmt.Println(handleQuery)
}

func TemplateRepo(name, dir string) {
	module := moduleReader()
	temp := fmt.Sprintf(
		`package %srepo

import (
	"database/sql"
	"%s/internal/model"
)

type %sRepository struct {
	db *sql.DB
}

type %sRepository interface {
	Show%s(page, size int, keyword string) ([]model.%sResponse, int, error)
	ShowById%s(id string) (model.%sResponse, error)
	Create%s(req model.%sRequest) error
	Update%s(data model.%sRequest, id string) error
	Delete%s(id string) error
	// Add function in here
}

func New%sRepository(db *sql.DB) %sRepository {
	return &%sRepository{db}
}

// Write code in here
func (q *%sRepository) Show%s(page, size int, keyword string) ([]model.%sResponse, int, error) {
	var count int
	if err := q.db.QueryRow(queryGet%sCount, %s+keyword+%s).Scan(&count); err != nil {
		return nil, 0, err
	}

	res, err := q.db.Query(queryGet%sWithPagination, %s+keyword+%s, size, page)
	if err != nil {
		return nil, 0, err
	}

	defer res.Close()

	var result []model.%sResponse
	for res.Next() {
		var data model.%sResponse

		if err := res.Scan(&data); err != nil {
			return nil, 0, err
		}

		result = append(result, data)
	}

	return result, count, nil
}

func (q *%sRepository) ShowById%s(id string) (model.%sResponse, error) {
	var data model.%sResponse
	if err := q.db.QueryRow(queryGet%sById, id).Scan(&data); err != nil {
		return model.%sResponse{}, err
	}

	return data, nil
}

func (q *%sRepository) Create%s(req model.%sRequest) error {

	if _, err := q.db.Exec(queryInsert%s, req); err != nil {
		return err
	}

	return nil
}

func (q *%sRepository) Update%s(data model.%sRequest, id string) error {

	if _, err := q.db.Exec("UPDATE %s SET name = $1 WHERE id = $2", data.Name, id); err != nil {
		return err
	}

	return nil
}

func (q *%sRepository) Delete%s(id string) error {

	if _, err := q.db.Exec(queryDelete%s, id); err != nil {
		return err
	}

	return nil
}
`, name, module, name, capitalize(name), capitalize(name), capitalize(name), capitalize(name), capitalize(name), capitalize(name), capitalize(name), capitalize(name), capitalize(name), capitalize(name), capitalize(name), capitalize(name), capitalize(name), name, name, capitalize(name), capitalize(name), `"%"`, `"%"`, capitalize(name), `"%"`, `"%"`, capitalize(name), capitalize(name), name, capitalize(name), capitalize(name), capitalize(name), capitalize(name), capitalize(name), name, capitalize(name), capitalize(name), capitalize(name), name, capitalize(name), capitalize(name), name, name, capitalize(name), capitalize(name),
	)

	handleQuery := process(temp, "repository/", dir+"_repo", "repository")
	fmt.Println(handleQuery)
}

func TemplateModel(name, dir string) {
	temp := fmt.Sprintf(
		"package model\n\n"+
			"import %s\n\n"+
			"type %sResponse struct {\n"+
			"\tID   uuid.UUID `json:\"id\"`\n"+
			"\tName string `json:\"name\"`\n"+
			"}\n\n"+
			"type %sRequest struct {\n"+
			"\tName string `json:\"name\"`\n"+
			"}\n",
		`"github.com/google/uuid"`, capitalize(name), capitalize(name),
	)

	handleQuery := process(temp, "model/", dir, name)
	fmt.Println(handleQuery)
}

func TemplateService() {}
