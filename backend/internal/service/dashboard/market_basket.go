package dashboardService

import (
	"context"
	"kavi-kasir/pkg/algoritma"
	"kavi-kasir/pkg/text"
)

func (s *dashboardService) GetMarketBasket(ctx context.Context) ([]string, error) {
	transactions, err := s.rekomRepo.GetProduk(ctx)
	if err != nil {
		return nil, err
	}

	data, err := s.rekomRepo.GetAllProduk(ctx)
	if err != nil {
		return nil, err
	}

	var d []string
	for _, v := range data {
		d = append(d, v.Nama)
	}

	var filtered [][]string
	for _, t := range transactions {
		if len(t) >= 2 {
			filtered = append(filtered, t)
		}
	}

	var x []string

	for _, b := range text.ToLowerSlice(d) {
		result := algoritma.MarketBasket(text.ToLower2D(filtered), []string{b})
		x = append(x, result...)
	}

	return text.UniqueCombinations(x), nil

}
