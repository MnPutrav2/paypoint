package rekomedasiModel

type RekomendasiResult struct {
	NamaProduk string   `json:"nama_produk"`
	List       []string `json:"list"`
}
