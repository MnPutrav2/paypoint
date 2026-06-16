package mapper

import (
	orderModel "kavi-kasir/internal/model/order"
	produkModel "kavi-kasir/internal/model/produk"
	"strconv"
)

func MappingSliceOrder(req []orderModel.OrderItem) []orderModel.OrderItemShow {
	ma := make([]orderModel.OrderItemShow, 0, len(req))
	for _, v := range req {
		ma = append(ma, orderModel.OrderItemShow{
			ID:         v.ID,
			OrderID:    v.OrderID,
			Produk:     v.NamaProduk,
			Jumlah:     v.Jumlah,
			TotalHarga: v.Jumlah * int(v.HargaJual),
		})
	}

	return ma
}

func MappingSingleOrder(req *orderModel.OrderItem) orderModel.OrderListShow {
	ma := orderModel.OrderListShow{
		ID:      req.ID,
		OrderID: req.OrderID,
		Produk: produkModel.ProdukShow{
			ID:     req.Katalog.Produk.ID,
			Nama:   req.Katalog.Produk.Nama,
			Detail: req.Katalog.Produk.Detail,
			Foto:   req.Katalog.Produk.Foto,
			Harga:  req.Katalog.Produk.Harga,
		},
		Jumlah:     req.Jumlah,
		TotalHarga: req.Jumlah * int(req.HargaJual),
	}

	return ma
}

func MappingSliceOrderList(req []orderModel.Order) []orderModel.OrderItemResult {
	ma := make([]orderModel.OrderItemResult, 0, len(req))
	for _, v := range req {
		i, _ := strconv.Atoi(v.Status.Deskripsi)

		ma = append(ma, orderModel.OrderItemResult{
			ID:           v.ID,
			Invoice:      v.Invoice,
			NamaCustomer: v.NamaCustomer,
			StatusINT:    i,
			Status:       string(v.Status.Nama),
			Total:        v.GrandTotal,
			Profit:       &v.Bayar.TotalProfit,
			Waktu:        v.Waktu,
		})
	}

	return ma
}

func MappingSingleOrderList(v orderModel.Order) orderModel.OrderItemResult {
	i, _ := strconv.Atoi(v.Status.Deskripsi)

	items := make([]orderModel.OrderItemShow, len(v.OrderItem))
	for i, item := range v.OrderItem {
		items[i] = orderModel.OrderItemShow{
			ID:         item.ID,
			OrderID:    item.OrderID,
			Produk:     item.NamaProduk,
			Jumlah:     item.Jumlah,
			Profit:     item.Profit,
			TotalHarga: int(item.SubTotal),
		}
	}
	return orderModel.OrderItemResult{
		ID:           v.ID,
		Invoice:      v.Invoice,
		NamaCustomer: v.NamaCustomer,
		Status:       string(v.Status.Nama),
		StatusINT:    i,
		Total:        v.GrandTotal,
		Profit:       &v.Bayar.TotalProfit,
		Waktu:        v.Waktu,
		Items:        items,
	}
}
