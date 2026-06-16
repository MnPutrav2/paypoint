package orderService

import (
	"context"
	"fmt"
	errorhttp "kavi-kasir/internal/http/error"
	orderModel "kavi-kasir/internal/model/order"
	stokModel "kavi-kasir/internal/model/stok"
	utilConst "kavi-kasir/pkg/util/const"
	"strings"

	"github.com/google/uuid"
)

func (s *orderService) UpdateOrder(ctx context.Context, id uuid.UUID, status string) (orderModel.Order, error) {
	stat, err := s.repo.GetOrderDataById(ctx, id)
	if err != nil {
		return orderModel.Order{}, err
	}

	newStatus, err := s.repo.GetKategori(ctx, status)
	if err != nil {
		return orderModel.Order{}, err
	}

	if stat.StatusID == newStatus.ID {
		return orderModel.Order{}, errorhttp.ErrOrder
	}

	tx := s.repo.BeginTx(ctx)
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	if status == "1" || status == "6" {
		res, err := s.repo.GetOrderItemByOrderId(ctx, id)
		if err != nil {
			tx.Rollback()
			return orderModel.Order{}, err
		}

		var errs []string
		for _, v := range res {
			c := stokModel.StokAdd{
				Stok: v.Jumlah,
				Tipe: "tambah",
			}

			if err := s.stok.UpdateStokData(v.Katalog.ProdukID, c); err != nil {
				errs = append(errs, err.Error())
			}
		}

		if len(errs) != 0 {
			tx.Rollback()
			return orderModel.Order{}, fmt.Errorf("%s", strings.Join(errs, ", "))
		}
	}

	if status == "2" {
		order, err := s.repo.GetOrderItemByOrderId(ctx, id)
		if err != nil {
			tx.Rollback()
			return orderModel.Order{}, err
		}

		var totalProfit int64
		for _, item := range order {
			totalProfit += item.Profit
		}

		if err := s.repoUser.UpdateSaldo(ctx, stat.UserID, totalProfit, utilConst.UpdateSaldoTambah); err != nil {
			tx.Rollback()
			return orderModel.Order{}, err
		}
	}

	result, err := s.repo.UpdateOrder(ctx, id, newStatus.ID)
	if err != nil {
		tx.Rollback()
		return orderModel.Order{}, err
	}

	if err := tx.Commit().Error; err != nil {
		return orderModel.Order{}, err
	}

	return result, nil
}
