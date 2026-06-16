package rekomendasiRepo

import (
	"context"
	"strings"

	"github.com/google/uuid"
)

type Result struct {
	OrderID uuid.UUID `json:"order_id"`
	Produk  *string   `json:"produk"` // pakai pointer
}

func (r *rekomendasiRepo) GetProduk(ctx context.Context) ([][]string, error) {
	var results []Result

	err := r.db.WithContext(ctx).
		Table("order_items").
		Select("order_id, STRING_AGG(DISTINCT nama_produk, '|' ORDER BY nama_produk) as produk").
		Group("order_id").
		Scan(&results).Error

	if err != nil {
		return nil, err
	}

	var transactions [][]string

	for _, res := range results {
		if res.Produk == nil || *res.Produk == "" {
			continue
		}

		items := strings.Split(*res.Produk, "|")

		// trim + unique
		items = cleanItems(items)

		// hanya ambil transaksi >= 2 item
		if len(items) < 2 {
			continue
		}

		transactions = append(transactions, items)
	}

	return transactions, nil
}

func cleanItems(items []string) []string {
	m := map[string]bool{}
	var result []string

	for _, item := range items {
		item = strings.TrimSpace(strings.ToLower(item))
		if item == "" {
			continue
		}
		if !m[item] {
			m[item] = true
			result = append(result, item)
		}
	}
	return result
}
