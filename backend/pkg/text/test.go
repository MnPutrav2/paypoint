package text

import (
	"sort"
	"strings"
)

func ToLowerSlice(items []string) []string {
	var result []string

	for _, item := range items {
		result = append(result, strings.ToLower(item))
	}

	return result
}

func ToLower2D(data [][]string) [][]string {
	var result [][]string

	for _, row := range data {
		var newRow []string
		for _, item := range row {
			newRow = append(newRow, strings.ToLower(item))
		}
		result = append(result, newRow)
	}

	return result
}

func normalizeCombination(s string) string {
	items := strings.Split(s, "+")

	for i := range items {
		items[i] = strings.TrimSpace(strings.ToLower(items[i]))
	}

	sort.Strings(items)

	return strings.Join(items, " + ")
}

func UniqueCombinations(data []string) []string {
	m := map[string]bool{}
	var result []string

	for _, item := range data {
		key := normalizeCombination(item)

		if !m[key] {
			m[key] = true
			result = append(result, key)
		}
	}

	return result
}
