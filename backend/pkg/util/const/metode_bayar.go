package utilConst

type BAYAR_TYPE struct {
	Desc string
}

type UPDATE_SALDO_TYPE string

var METODE_PEMBAYARAN = map[string]BAYAR_TYPE{
	"TUNAI":     {Desc: "1"},
	"NON_TUNAI": {Desc: "2"},
}

const (
	UpdateSaldoTambah UPDATE_SALDO_TYPE = "+"
	UpdateSaldoKurang UPDATE_SALDO_TYPE = "-"
)
