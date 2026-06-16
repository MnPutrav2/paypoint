package form

import (
	"errors"
	"net/http"
	"strconv"
	"strings"

	"github.com/google/uuid"
)

func IsEmptyForm(r *http.Request, v []any, req []string) ([]any, error) {
	var errs []string
	var val []any

	for c, i := range req {
		form := r.FormValue(i)

		if form == "" {
			emp := "empty " + i
			errs = append(errs, emp)
		} else {
			switch any(v[c]).(type) {
			case string:
				val = append(val, form)
			case int:
				r, _ := strconv.Atoi(form)
				val = append(val, r)
			case uuid.UUID:
				r, _ := uuid.Parse(form)
				val = append(val, r)
			}
		}
	}

	var z []any
	if len(errs) != 0 {
		return z, errors.New(strings.Join(errs, ", "))
	}

	return val, nil
}
