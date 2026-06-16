package orderRepo

import (
	"context"
	"fmt"
	katalogModel "kavi-kasir/internal/model/katalog"
	orderModel "kavi-kasir/internal/model/order"
)

func (q *orderRepository) CheckPrice(ctx context.Context, o orderModel.OrderAdd) (int64, error) {
	var total int64

	for _, v := range o.OrderItem {
		var t katalogModel.Katalog

		if err := q.db.WithContext(ctx).Model(&katalogModel.Katalog{}).Where("id = ?", v.KatalogID).Scan(&t).Error; err != nil {
			return 0, err
		}

		total += int64(t.Harga) * int64(v.Jumlah)
	}

	fmt.Println("total = ", total)
	return total, nil
}
