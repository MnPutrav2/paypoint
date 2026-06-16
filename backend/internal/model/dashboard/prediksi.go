package dashboardModel

// PrediksiOmzet adalah hasil prediksi linear regression untuk dashboard.
type PrediksiOmzet struct {
	// BulanPrediksi adalah label bulan target prediksi, contoh: "Mei 2025"
	BulanPrediksi string `json:"bulan_prediksi"`

	// NilaiPrediksi adalah estimasi total omzet bulan depan (dalam Rupiah)
	NilaiPrediksi float64 `json:"nilai_prediksi"`

	// BatasAtas adalah batas atas confidence interval (NilaiPrediksi + 1 std error)
	BatasAtas float64 `json:"batas_atas"`

	// BatasBawah adalah batas bawah confidence interval (NilaiPrediksi - 1 std error)
	BatasBawah float64 `json:"batas_bawah"`

	// Tren menunjukkan arah tren: "naik", "turun", atau "stabil"
	Tren string `json:"tren"`

	// Akurasi adalah nilai R² dalam persen (0-100), menunjukkan seberapa baik model fit
	Akurasi float64 `json:"akurasi"`

	// DataHistoris adalah slice omzet per bulan yang dipakai sebagai input model
	DataHistoris []OmzetBulanan `json:"data_historis"`

	// CukupData menandakan apakah data historis cukup untuk prediksi (min. 3 bulan)
	CukupData bool `json:"cukup_data"`
}

// OmzetBulanan adalah satu titik data historis omzet.
type OmzetBulanan struct {
	Bulan  string  `json:"bulan"`  // Label, contoh: "Jan 2025"
	Omzet  float64 `json:"omzet"`  // Total omzet bulan tersebut
	Indeks int     `json:"indeks"` // Indeks urutan (1, 2, 3, ...) untuk sumbu X regresi
}
