package regression

import "math"

// Point merepresentasikan satu titik data (x=indeks bulan, y=nilai omzet)
type Point struct {
	X float64
	Y float64
}

// Result menyimpan hasil kalkulasi linear regression
type Result struct {
	Slope     float64 // kemiringan garis (positif = naik, negatif = turun)
	Intercept float64 // titik potong sumbu Y
	R2        float64 // koefisien determinasi (0-1, semakin tinggi semakin akurat)
	Trend     string  // "naik", "turun", atau "stabil"
}

// Calculate menghitung linear regression dari sekumpulan titik data.
// Menggunakan metode Ordinary Least Squares (OLS):
//
//	slope     = (n*Σxy - Σx*Σy) / (n*Σx² - (Σx)²)
//	intercept = (Σy - slope*Σx) / n
func Calculate(points []Point) Result {
	n := float64(len(points))
	if n < 2 {
		return Result{Trend: "stabil"}
	}

	var sumX, sumY, sumXY, sumX2, sumY2 float64
	for _, p := range points {
		sumX += p.X
		sumY += p.Y
		sumXY += p.X * p.Y
		sumX2 += p.X * p.X
		sumY2 += p.Y * p.Y
	}

	denom := n*sumX2 - sumX*sumX
	if denom == 0 {
		return Result{Trend: "stabil"}
	}

	slope := (n*sumXY - sumX*sumY) / denom
	intercept := (sumY - slope*sumX) / n

	// Hitung R² (koefisien determinasi)
	meanY := sumY / n
	var ssTot, ssRes float64
	for _, p := range points {
		predicted := slope*p.X + intercept
		ssRes += math.Pow(p.Y-predicted, 2)
		ssTot += math.Pow(p.Y-meanY, 2)
	}

	r2 := 0.0
	if ssTot != 0 {
		r2 = 1 - ssRes/ssTot
	}

	trend := classifyTrend(slope, sumY/n)

	return Result{
		Slope:     slope,
		Intercept: intercept,
		R2:        math.Round(r2*10000) / 10000,
		Trend:     trend,
	}
}

// Predict menghitung nilai prediksi untuk nilai X tertentu.
// Contoh: Predict(result, 7.0) → prediksi omzet bulan ke-7
func Predict(r Result, x float64) float64 {
	val := r.Slope*x + r.Intercept
	if val < 0 {
		return 0
	}
	return math.Round(val)
}

// classifyTrend menentukan tren berdasarkan slope relatif terhadap rata-rata omzet.
// Threshold 2% dipakai agar noise kecil tidak dianggap tren berarti.
func classifyTrend(slope, meanY float64) string {
	if meanY == 0 {
		return "stabil"
	}
	relativeChange := slope / meanY
	switch {
	case relativeChange > 0.02:
		return "naik"
	case relativeChange < -0.02:
		return "turun"
	default:
		return "stabil"
	}
}
