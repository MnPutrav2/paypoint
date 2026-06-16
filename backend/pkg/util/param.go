package util

import (
	"fmt"
	"net/http"
	"strconv"
	"strings"

	"github.com/google/uuid"
)

func Param(r *http.Request, path string) (string, int, error) {
	idStr := strings.TrimPrefix(r.URL.Path, path)
	idStr = strings.TrimSuffix(idStr, "/")

	if idStr == "" {
		return "empty id", 0, fmt.Errorf("empty ID")
	}

	id, err := strconv.Atoi(idStr)
	if err != nil {
		return "id must integer", 0, fmt.Errorf("id must integer")
	}

	return "success", id, nil
}

func ParamStr(r *http.Request, path string) (string, string, error) {
	idStr := strings.TrimPrefix(r.URL.Path, path)
	idStr = strings.Trim(idStr, "/")

	if strings.TrimSpace(idStr) == "" {
		return "empty id", "", fmt.Errorf("empty ID")
	}

	return "success", idStr, nil
}

func GetParameter(r *http.Request, path string) (uuid.UUID, string, error) {
	message, id, err := ParamStr(r, path)
	if err != nil {
		return uuid.Nil, message, err
	}

	uid, err := uuid.Parse(id)
	if err != nil {
		return uuid.Nil, "invalid parameter", err
	}

	return uid, "success", nil
}
