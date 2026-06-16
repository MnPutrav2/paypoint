package dashboardService

import (
	"context"
	dashboardModel "kavi-kasir/internal/model/dashboard"
	jwtEnc "kavi-kasir/pkg/auth/jwt"
	utilConst "kavi-kasir/pkg/util/const"
)

// Semua query jalan paralel — lebih cepat
func (s *dashboardService) GetDashboard(ctx context.Context, mode utilConst.GrafikMode) (dashboardModel.Dashboard, error) {
	userID := ctx.Value(utilConst.ContextUserID).(*jwtEnc.Claims).UserID

	from, to := utilConst.GetDateRange(mode)

	type result[T any] struct {
		val T
		err error
	}

	saldoCh := make(chan result[int64], 1)
	totalOmzetCh := make(chan result[int64], 1)
	profitHariIniCh := make(chan result[int64], 1)
	totalProfitCh := make(chan result[int64], 1)
	itemTerjualCh := make(chan result[int64], 1)
	transaksiPendingCh := make(chan result[int64], 1)
	grafikOmzetCh := make(chan result[[]dashboardModel.Grafik], 1)
	grafikItemCh := make(chan result[[]dashboardModel.Grafik], 1)
	prediksiCh := make(chan result[*dashboardModel.PrediksiOmzet], 1) // ← tambah
	marketBasketCh := make(chan result[*[]string], 1)                 // ← tambah

	go func() {
		v, err := s.userRepo.GetSaldo(ctx, userID)
		saldoCh <- result[int64]{v, err}
	}()
	go func() {
		v, err := s.orderRepo.GetTotalOmzet(ctx)
		totalOmzetCh <- result[int64]{v, err}
	}()
	go func() {
		v, err := s.orderRepo.GetProfitHariIni(ctx)
		profitHariIniCh <- result[int64]{v, err}
	}()
	go func() {
		v, err := s.orderRepo.GetTotalProfit(ctx)
		totalProfitCh <- result[int64]{v, err}
	}()
	go func() {
		v, err := s.orderRepo.GetItemTerjual(ctx)
		itemTerjualCh <- result[int64]{v, err}
	}()
	go func() {
		v, err := s.orderRepo.GetTransaksiBelumSelesai(ctx)
		transaksiPendingCh <- result[int64]{v, err}
	}()
	go func() {
		v, err := s.orderRepo.GetGrafikOmzet(ctx, from, to, mode)
		grafikOmzetCh <- result[[]dashboardModel.Grafik]{v, err}
	}()
	go func() {
		v, err := s.orderRepo.GetGrafikItemTerlaris(ctx, from, to)
		grafikItemCh <- result[[]dashboardModel.Grafik]{v, err}
	}()

	go func() { // ← tambah
		v, err := s.GetPrediksi(ctx)
		prediksiCh <- result[*dashboardModel.PrediksiOmzet]{v, err}
	}()
	go func() { // ← tambah
		v, err := s.GetMarketBasket(ctx)
		marketBasketCh <- result[*[]string]{&v, err}
	}()

	saldo := <-saldoCh
	totalOmzet := <-totalOmzetCh
	profitHariIni := <-profitHariIniCh
	totalProfit := <-totalProfitCh
	itemTerjual := <-itemTerjualCh
	transaksiPending := <-transaksiPendingCh
	grafikOmzet := <-grafikOmzetCh
	grafikItem := <-grafikItemCh
	prediksi := <-prediksiCh
	marketBasket := <-marketBasketCh

	// cek semua error
	for _, err := range []error{
		saldo.err, totalOmzet.err, profitHariIni.err,
		totalProfit.err, itemTerjual.err, transaksiPending.err,
		grafikOmzet.err, grafikItem.err,
		prediksi.err, marketBasket.err, // ← tambah
	} {
		if err != nil {
			return dashboardModel.Dashboard{}, err
		}
	}

	return dashboardModel.Dashboard{
		Saldo:                 saldo.val,
		TotalOmzet:            totalOmzet.val,
		ProfitHariIni:         profitHariIni.val,
		TotalProfit:           totalProfit.val,
		ItemTerjual:           itemTerjual.val,
		TransaksiBelumSelesai: transaksiPending.val,
		GrafikOmzet:           grafikOmzet.val,
		GrafikItemTerjual:     grafikItem.val,
		PrediksiOmzet:         prediksi.val,
		MarketBasket:          marketBasket.val,
	}, nil
}
