package mapper

import (
	midtransModel "kavi-kasir/internal/model/midtrans"
	orderModel "kavi-kasir/internal/model/order"
)

func MappingMidtransRequest(req []orderModel.OrderItem) []midtransModel.ItemDetails {
	ma := make([]midtransModel.ItemDetails, 0, len(req))
	for _, v := range req {
		ma = append(ma, midtransModel.ItemDetails{
			ID:       v.ID.String(),
			Price:    int64(v.HargaJual),
			Quantity: v.Jumlah,
			Name:     v.Katalog.Produk.Nama,
		})
	}

	return ma
}
