package utilConst

type STATUS_TYPE struct {
	Desc  string
	Label string
}

var REF_STATUS_PEMBAYARAN string = "status pembayaran"
var STATUS_PEMBAYARAN = map[string]STATUS_TYPE{
	"BATAL":       {Label: "batal", Desc: "1"},
	"SELESAI":     {Label: "selesai", Desc: "2"},
	"DIPROSES":    {Label: "diproses", Desc: "3"},
	"SUDAH_BAYAR": {Label: "sudah bayar", Desc: "4"},
	"BELUM_BAYAR": {Label: "belum bayar", Desc: "5"},
	"EXPIRED":     {Label: "expired", Desc: "6"},
	"PENDING":     {Label: "pending", Desc: "7"},
}
