package dashboardModel

type Dashboard struct {
	Saldo                 int64          `json:"saldo"`
	TotalOmzet            int64          `json:"total_omzet"`
	ProfitHariIni         int64          `json:"profit_hari_ini"`
	TotalProfit           int64          `json:"total_profit"`
	ItemTerjual           int64          `json:"item_terjual"`
	TransaksiBelumSelesai int64          `json:"transaksi_belum_selesai"`
	GrafikOmzet           []Grafik       `json:"grafik_omzet"`
	GrafikItemTerjual     []Grafik       `json:"grafik_item_terlaris"`
	PrediksiOmzet         *PrediksiOmzet `json:"prediksi_omzet"`
	MarketBasket          *[]string      `json:"market_basket"`
}

type Grafik struct {
	Label string `json:"label"`
	Value int64  `json:"value"`
}
