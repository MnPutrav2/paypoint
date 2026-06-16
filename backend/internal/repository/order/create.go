package orderRepo

import (
	"context"
	katalogModel "kavi-kasir/internal/model/katalog"
	orderModel "kavi-kasir/internal/model/order"
	"time"

	"github.com/google/uuid"
)

func (q *orderRepository) CreateOrder(ctx context.Context, o orderModel.OrderAdd, customer *string, user uuid.UUID, total int64, invoice string, u uuid.UUID) (orderModel.Order, error) {

	order := orderModel.Order{
		ID:           uuid.New(),
		Invoice:      invoice,
		Waktu:        time.Now(),
		UserID:       user,
		NamaCustomer: o.NamaCustomer,
		StatusID:     u,
		GrandTotal:   o.Total,
	}

	if err := q.db.WithContext(ctx).Create(&order).Error; err != nil {
		return orderModel.Order{}, err
	}

	var orderList []orderModel.OrderItem
	for _, v := range o.OrderItem {

		var p katalogModel.Katalog
		if err := q.db.WithContext(ctx).Model(&katalogModel.Katalog{}).
			Preload("Produk").Where("id = ?", v.KatalogID).Find(&p).Error; err != nil {
			return orderModel.Order{}, err
		}

		x := orderModel.OrderItem{
			OrderID:    order.ID,
			NamaProduk: p.Produk.Nama,
			KatalogID:  p.ID,
			Jumlah:     v.Jumlah,
			HargaJual:  int64(p.Harga),
			HargaModal: int64(p.Produk.Harga),
			SubTotal:   int64(v.Jumlah) * int64(p.Harga),
			Profit:     int64(v.Jumlah)*int64(p.Harga) - (int64(v.Jumlah) * int64(p.Produk.Harga)),
		}
		// x := orderModel.OrderItem{
		// 	OrderID:   order.ID,
		// 	KatalogID: v.KatalogID,
		// 	ProdukID:  p.ProdukID,
		// 	Jumlah:    v.Jumlah,
		// }

		orderList = append(orderList, x)
	}

	if err := q.db.WithContext(ctx).Create(&orderList).Error; err != nil {
		return orderModel.Order{}, err
	}

	return order, nil
}
