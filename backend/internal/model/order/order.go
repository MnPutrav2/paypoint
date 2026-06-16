package orderModel

import (
	katalogModel "kavi-kasir/internal/model/katalog"
	kategoriModel "kavi-kasir/internal/model/kategori"
	produkModel "kavi-kasir/internal/model/produk"
	userModel "kavi-kasir/internal/model/user"
	"time"

	"github.com/google/uuid"
)

type status string

const (
	batal   status = "batal"
	selesai status = "selesai"
	proses  status = "proses"
	belum   status = "belum bayar"
	sudah   status = "sudah bayar"
)

type Order struct {
	ID           uuid.UUID              `json:"id" gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	Waktu        time.Time              `json:"waktu" gorm:"not null;default:now()"`
	Invoice      string                 `json:"invoice" gorm:"type:varchar(80);not null"`
	NamaCustomer *string                `json:"nama_customer" gorm:"type:varchar(80)"`
	UserID       uuid.UUID              `json:"user_id" gorm:"type:uuid;not null"`
	User         userModel.User         `json:"user" gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
	StatusID     uuid.UUID              `json:"status_id" gorm:"type:uuid;not null"`
	Status       kategoriModel.Kategori `json:"status" gorm:"foreignKey:StatusID;constraint:OnDelete:CASCADE;"`
	Catatan      *string                `json:"catatan"`
	GrandTotal   int64                  `json:"grand_total"`
	CreatedAt    time.Time              `json:"-" gorm:"not null;default:now()"`
	UpdatedAt    time.Time              `json:"-" gorm:"not null;default:now()"`

	Bayar     OrderPay    `gorm:"foreignKey:OrderID"`
	OrderItem []OrderItem `gorm:"foreignKey:OrderID"`
}
type OrderPay struct {
	ID      uuid.UUID `json:"id" gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	OrderID uuid.UUID `gorm:"type:uuid;not null;index"`
	// Order              Order                  `gorm:"foreignKey:OrderID;constraint:OnDelete:CASCADE"`
	MetodePembayaranID uuid.UUID              `json:"metode_pembayaran_id" gorm:"type:uuid;not null"`
	MetodePembayaran   kategoriModel.Kategori `json:"metode_pembayaran" gorm:"foreignKey:MetodePembayaranID;constraint:OnDelete:CASCADE;"`
	UangDibayar        int64                  `json:"uang_dibayar" gorm:"not null"`
	Kembalian          int64                  `json:"kembalian"`
	SubTotal           int64                  `json:"subtotal"`
	Potongan           *int64                 `json:"potongan"`
	Pajak              *int64                 `json:"pajak"`
	TotalProfit        int64                  `json:"total_profit"`
	Total              int64                  `json:"total"`
	SnapToken          *uuid.UUID             `json:"snap_token" gorm:"uuid"`
	CreatedAt          time.Time
	UpdatedAt          time.Time
}

type OrderItem struct {
	ID      uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	OrderID uuid.UUID `gorm:"type:uuid;not null"`
	Order   Order     `gorm:"foreignKey:OrderID;constraint:OnDelete:CASCADE"`

	KatalogID uuid.UUID            `gorm:"type:uuid;not null"`
	Katalog   katalogModel.Katalog `json:"katalog" gorm:"foreignKey:KatalogID;constraint:OnDelete:CASCADE;"`

	NamaProduk string `gorm:"type:varchar(120);not null"`

	HargaJual  int64 `gorm:"not null"`
	HargaModal int64 `gorm:"not null"`

	Jumlah int `gorm:"not null"`

	SubTotal int64 `gorm:"not null"`
	Profit   int64 `gorm:"not null"`

	CreatedAt time.Time
	UpdatedAt time.Time
}

type OrderAdd struct {
	OrderItem    []OrderItemAdd `json:"order_item"`
	NamaCustomer *string        `json:"nama_customer"`
	Total        int64          `json:"total"`
	Catatan      *string        `json:"catatan"`
}
type OrderItemAdd struct {
	KatalogID uuid.UUID `json:"katalog_id"`
	Jumlah    int       `json:"jumlah"`
	Subtotal  int       `json:"subtotal"`
}

type OrderPayload struct {
	OrderItem []OrderItemAdd `json:"order_item"`
	// Order        OrderAdd `json:"order_item"`
	Total        int64   `json:"total"`
	NamaCustomer *string `json:"nama_customer"`
}

type OrderShow struct {
	ID    uuid.UUID       `json:"id" gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	Waktu time.Time       `json:"waktu" gorm:"not null;default:now()"`
	List  []OrderListShow `json:"list"`
}
type OrderDetailShow struct {
	ID    uuid.UUID       `json:"id" gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	Waktu time.Time       `json:"waktu" gorm:"not null;default:now()"`
	List  []OrderListShow `json:"list"`
	Pays  []OrderPay      `json:"riwayat_bayar"`
}

type OrderListShow struct {
	ID         uuid.UUID              `json:"id"`
	OrderID    uuid.UUID              `json:"order_id"`
	Produk     produkModel.ProdukShow `json:"produk"`
	Jumlah     int                    `json:"jumlah"`
	TotalHarga int                    `json:"total_harga"`
}
type OrderItemShow struct {
	ID         uuid.UUID `json:"id"`
	OrderID    uuid.UUID `json:"order_id"`
	Produk     string    `json:"produk"`
	Jumlah     int       `json:"jumlah"`
	Profit     int64     `json:"profit"`
	TotalHarga int       `json:"total_harga"`
}
type OrderItemResult struct {
	ID           uuid.UUID       `json:"id"`
	Invoice      string          `json:"invoice"`
	NamaCustomer *string         `json:"nama_customer"`
	StatusINT    int             `json:"status_int"`
	Status       string          `json:"status"`
	Total        int64           `json:"total"`
	Profit       *int64          `json:"profit"`
	Waktu        time.Time       `json:"created_at"`
	Items        []OrderItemShow `json:"items"`
}

type OrderSetStatus struct {
	Status int `json:"status"`
}

type OrderRes struct {
	ID           uuid.UUID `json:"id"`
	Waktu        time.Time `json:"waktu"`
	Invoice      string    `json:"invoice"`
	NamaCustomer *string   `json:"nama_customer"`
	Status       string    `json:"status"`
	Total        int       `json:"total"`
	CreatedAt    time.Time `json:"-" gorm:"not null;default:now()"`
	UpdatedAt    time.Time `json:"-" gorm:"not null;default:now()"`
}

//	type OrderItem struct {
//		ID        uuid.UUID            `json:"id" gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
//		OrderID   uuid.UUID            `json:"order_id" gorm:"type:uuid;not null"`
//		Order     Order                `json:"order" gorm:"foreignKey:OrderID;constraint:OnDelete:CASCADE;"`
//		KatalogID uuid.UUID            `json:"katalog_id" gorm:"type:uuid;not null"`
//		Katalog   katalogModel.Katalog `json:"katalog" gorm:"foreignKey:KatalogID;constraint:OnDelete:CASCADE;"`
//		ProdukID  uuid.UUID            `json:"produk_id" gorm:"type:uuid;not null"`
//		Produk    produkModel.Produk   `json:"produk" gorm:"foreignKey:ProdukID;constraint:OnDelete:CASCADE;"`
//		Jumlah    int                  `json:"jumlah" gorm:"type:decimal;not null"`
//		CreatedAt time.Time            `json:"-" gorm:"not null;default:now()"`
//		UpdatedAt time.Time            `json:"-" gorm:"not null;default:now()"`
//	}
