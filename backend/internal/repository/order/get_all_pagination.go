package orderRepo

import (
	"context"
	"fmt"
	orderModel "kavi-kasir/internal/model/order"
	"kavi-kasir/pkg/auth"
	"strings"
)

func (r *orderRepository) GetAllOrderIdPaginated(ctx context.Context,
	page,
	size int,
	keyword string,
	sortColumn string,
	sortDirection string,
) ([]orderModel.Order, int, error) {
	var (
		order []orderModel.Order
		total int64
	)

	user := auth.GetUser(ctx)
	q := r.db.WithContext(ctx).Model(&orderModel.Order{}).Where("user_id = ?", user.UserID)

	if keyword != "" {
		search := "%" + keyword + "%"
		q = q.Where(
			"(invoice ILIKE ? OR nama_customer ILIKE ?)",
			search,
			search,
		)
	}

	if err := q.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	allowedColumns := map[string]string{
		"waktu":         "waktu",
		"created_at":    "created_at",
		"updated_at":    "updated_at",
		"invoice":       "invoice",
		"nama_customer": "nama_customer",
		"total_harga":   "total_harga",
	}

	column, ok := allowedColumns[sortColumn]
	if !ok {
		column = "waktu"
	}

	direction := "DESC"
	if strings.EqualFold(sortDirection, "asc") {
		direction = "ASC"
	}

	orderBy := fmt.Sprintf("%s %s", column, direction)

	if err := q.Preload("Status").
		Order(orderBy).Limit(size).Offset(page).Find(&order).Error; err != nil {
		return nil, 0, err
	}

	return order, int(total), nil
}
