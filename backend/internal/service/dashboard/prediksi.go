package dashboardService

import (
	"context"
	"fmt"
	"math"
	"time"

	dashboardModel "kavi-kasir/internal/model/dashboard"
	orderRepo "kavi-kasir/internal/repository/order"
	"kavi-kasir/pkg/regression"
)

const (
	minDataBulan = 3  // minimum bulan agar prediksi valid
	windowBulan  = 12 // ambil 12 bulan terakhir sebagai window
)

// GetPrediksi mengambil data historis omzet, menjalankan linear regression,
// lalu mengembalikan prediksi omzet bulan berikutnya beserta metadata tren.
func (s *dashboardService) GetPrediksi(ctx context.Context) (*dashboardModel.PrediksiOmzet, error) {
	// 1. Ambil data omzet bulanan dari repository
	// 1. Ambil data omzet bulanan
	rows, err := s.orderRepo.GetOmzetBulanan(ctx, 12)
	if err != nil {
		return nil, fmt.Errorf("prediksi: %w", err)
	}

	now := time.Now()
	nextMonth := now.AddDate(0, 1, 0)

	// ✅ hanya sampai bulan sekarang (bukan nextMonth)
	rows = generateFullMonths(rows, now)

	historis := make([]dashboardModel.OmzetBulanan, 0, len(rows))
	points := make([]regression.Point, 0, len(rows))

	for i, row := range rows {
		historis = append(historis, dashboardModel.OmzetBulanan{
			Bulan:  bulanLabel(row.Tahun, row.Bulan),
			Omzet:  row.Total,
			Indeks: i + 1,
		})

		points = append(points, regression.Point{
			X: float64(i + 1),
			Y: row.Total,
		})
	}

	// ❗ validasi minimal data
	if len(points) < 3 {
		return &dashboardModel.PrediksiOmzet{
			CukupData:    false,
			DataHistoris: historis,
		}, nil
	}

	// 🔥 regression
	result := regression.Calculate(points)

	// 🔥 prediksi bulan berikutnya
	nextX := float64(len(points) + 1)
	nilaiPrediksi := regression.Predict(result, nextX)

	stdErr := hitungStdError(points, result)

	return &dashboardModel.PrediksiOmzet{
		BulanPrediksi: bulanLabel(nextMonth.Year(), int(nextMonth.Month())),
		NilaiPrediksi: nilaiPrediksi,
		BatasAtas:     math.Round(nilaiPrediksi + stdErr),
		BatasBawah:    math.Max(0, math.Round(nilaiPrediksi-stdErr)),
		Tren:          result.Trend,
		Akurasi:       math.Round(result.R2*10000) / 100,

		// ✅ bersih (tidak ada bulan prediksi)
		DataHistoris: historis,

		CukupData: true,
	}, nil
}

// hitungStdError menghitung standard error of the estimate (SEE).
// Digunakan sebagai lebar confidence interval ±1 SEE.
func hitungStdError(points []regression.Point, r regression.Result) float64 {
	n := float64(len(points))
	if n < 3 {
		return 0
	}
	var ssRes float64
	for _, p := range points {
		predicted := r.Slope*p.X + r.Intercept
		ssRes += math.Pow(p.Y-predicted, 2)
	}
	return math.Sqrt(ssRes / (n - 2))
}

// bulanLabel menghasilkan label manusiawi, contoh: "Jan 2025"
func bulanLabel(year, month int) string {
	t := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.UTC)
	return t.Format("Jan 2006")
}

func generateFullMonths(
	rows []orderRepo.OmzetBulananRow,
	endDate time.Time,
) []orderRepo.OmzetBulananRow {

	if len(rows) == 0 {
		return rows
	}

	dataMap := make(map[string]float64)
	for _, r := range rows {
		key := fmt.Sprintf("%04d-%02d", r.Tahun, r.Bulan)
		dataMap[key] = r.Total
	}

	// start dari data pertama
	start := time.Date(rows[0].Tahun, time.Month(rows[0].Bulan), 1, 0, 0, 0, 0, time.Local)

	// 🔥 end pakai parameter (bukan dari rows)
	end := time.Date(endDate.Year(), endDate.Month(), 1, 0, 0, 0, 0, time.Local)

	var result []orderRepo.OmzetBulananRow
	current := start

	for !current.After(end) {
		key := fmt.Sprintf("%04d-%02d", current.Year(), int(current.Month()))

		total := dataMap[key]

		result = append(result, orderRepo.OmzetBulananRow{
			Tahun: current.Year(),
			Bulan: int(current.Month()),
			Total: total,
		})

		current = current.AddDate(0, 1, 0)
	}

	return result
}
