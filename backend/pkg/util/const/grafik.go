package utilConst

import (
	"fmt"
	dashboardModel "kavi-kasir/internal/model/dashboard"
	"time"
)

type GRAFIK_TYPE struct {
	Label string `gorm:"column:label"`
	Value int64  `gorm:"column:total"`
}

type GrafikMode string

const (
	GrafikMinggu GrafikMode = "minggu"
	GrafikBulan  GrafikMode = "bulan"
	GrafikTahun  GrafikMode = "tahun"
)

func GetDateRange(mode GrafikMode) (from, to time.Time) {
	now := time.Now()
	switch mode {
	case GrafikMinggu:
		// Senin minggu ini sampai hari ini
		from = now.AddDate(0, 0, -int(now.Weekday())+1)
		from = time.Date(from.Year(), from.Month(), from.Day(), 0, 0, 0, 0, from.Location())
	case GrafikBulan:
		// Tanggal 1 bulan ini sampai hari ini
		from = time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())
	case GrafikTahun:
		// 1 Januari tahun ini sampai hari ini
		from = time.Date(now.Year(), 1, 1, 0, 0, 0, 0, now.Location())
	}
	to = time.Date(now.Year(), now.Month(), now.Day(), 23, 59, 59, 0, now.Location())
	return
}

func MapToGrafik(rows []GRAFIK_TYPE, mode GrafikMode, from time.Time) []dashboardModel.Grafik {
	dataMap := make(map[string]int64)
	for _, r := range rows {
		dataMap[r.Label] = r.Value
	}

	var result []dashboardModel.Grafik

	switch mode {
	case GrafikMinggu:
		// urutan Senin - Minggu (DAYOFWEEK: 2=Senin ... 1=Minggu)
		labels := []struct{ key, label string }{
			{"2", "Senin"}, {"3", "Selasa"}, {"4", "Rabu"}, {"5", "Kamis"},
			{"6", "Jumat"}, {"7", "Sabtu"}, {"1", "Minggu"},
		}
		for _, l := range labels {
			result = append(result, dashboardModel.Grafik{Label: l.label, Value: dataMap[l.key]})
		}

	case GrafikBulan:
		// hari 1 - akhir bulan
		daysInMonth := time.Date(from.Year(), from.Month()+1, 0, 0, 0, 0, 0, from.Location()).Day()
		for d := 1; d <= daysInMonth; d++ {
			key := fmt.Sprintf("%d", d)
			result = append(result, dashboardModel.Grafik{
				Label: fmt.Sprintf("%d", d),
				Value: dataMap[key],
			})
		}

	case GrafikTahun:
		// Jan - Des
		bulan := []string{"Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des"}
		for i, b := range bulan {
			key := fmt.Sprintf("%d", i+1)
			result = append(result, dashboardModel.Grafik{Label: b, Value: dataMap[key]})
		}
	}

	return result
}
