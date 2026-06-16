package payModel

import (
	kategoriModel "kavi-kasir/internal/model/kategori"
	orderModel "kavi-kasir/internal/model/order"

	"github.com/google/uuid"
)

type PayRequest struct {
	OrderID            uuid.UUID              `json:"order_id"`
	Order              orderModel.Order       `json:"order" gorm:"foreignKey:OrderID;constraint:OnDelete:CASCADE"`
	MetodePembayaranID uuid.UUID              `json:"metode_pembayaran_id"`
	MetodePembayaran   kategoriModel.Kategori `json:"metode_pembayaran" gorm:"foreignKey:MetodePembayaranID;constraint:OnDelete:CASCADE;"`
	UangDibayar        int64                  `json:"uang_dibayar"`
	Potongan           *int64                 `json:"potongan"`
}

type PayResponse struct {
	ID     *uuid.UUID              `json:"id,omitempty"`
	Status *kategoriModel.Kategori `json:"status,omitempty"`

	// Untuk NON_TUNAI (Midtrans)
	Token       uuid.UUID `json:"snap_token,omitempty"`
	RedirectURL string    `json:"redirect_url,omitempty"`

	Data *orderModel.Order `json:"data"`
}
