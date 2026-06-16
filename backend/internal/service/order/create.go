package orderService

import (
	"context"
	"errors"
	"fmt"
	errorhttp "kavi-kasir/internal/http/error"
	orderModel "kavi-kasir/internal/model/order"
	"kavi-kasir/pkg/invoice"
	"strings"
	"time"

	"github.com/google/uuid"
)

func (s *orderService) Create(ctx context.Context, o orderModel.OrderAdd, user uuid.UUID, total int64) (orderModel.Order, error) {
	var errx []string
	for _, v := range o.OrderItem {
		if err := s.stok.CheckStock(v.KatalogID, v.Jumlah); err != nil {
			errx = append(errx, err.Error())
		}
	}

	ch, err := s.repo.CheckPrice(ctx, o)
	if err != nil {
		return orderModel.Order{}, err
	}

	if ch != total {
		return orderModel.Order{}, errorhttp.ErrOrderPri
	}

	next, err := s.repo.CheckCount(ctx, time.Now())
	if err != nil {
		return orderModel.Order{}, err
	}

	idu, err := s.repo.GetKategori(ctx, "5")
	if err != nil {
		return orderModel.Order{}, err
	}

	inv := invoice.Generate(next)
	data, err := s.repo.CreateOrder(ctx, o, o.NamaCustomer, user, total, inv, idu.ID)
	if err != nil {
		return orderModel.Order{}, err
	}

	var errc []string
	for _, v := range o.OrderItem {
		if err := s.stok.DecrementStok(v.KatalogID, v.Jumlah); err != nil {
			errc = append(errc, err.Error())
		}
	}

	if len(errc) != 0 {
		fmt.Println(errc)
		return orderModel.Order{}, errors.New(strings.Join(errc, ", "))
	}

	return data, nil
}
