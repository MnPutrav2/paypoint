package payService

import (
	"context"
	"fmt"
	"kavi-kasir/internal/mapper"
	orderModel "kavi-kasir/internal/model/order"
	payModel "kavi-kasir/internal/model/pay"
	"kavi-kasir/pkg/midtrans"
	utilConst "kavi-kasir/pkg/util/const"
	"os"
	"strings"

	"github.com/google/uuid"
	"github.com/joho/godotenv"
)

func (s *payService) CreatePayment(ctx context.Context, p payModel.PayRequest) (payModel.PayResponse, error) {
	_ = godotenv.Load()
	refStatusBayar := utilConst.REF_STATUS_PEMBAYARAN
	statusBayar := utilConst.STATUS_PEMBAYARAN
	metodeBayar := utilConst.METODE_PEMBAYARAN
	res, list, err := s.repo.GetOrderList(ctx, p.OrderID)

	_ = godotenv.Load()
	if err != nil {
		return payModel.PayResponse{}, err
	}
	order, err := s.repo2.GetOrderDataById(ctx, p.OrderID)
	if err != nil {
		return payModel.PayResponse{}, err
	}
	bayarID, err := s.repoKat.GetById(ctx, p.MetodePembayaranID)
	if err != nil {
		return payModel.PayResponse{}, err
	}
	kembalian := p.UangDibayar - res.GrandTotal
	var potongan int64
	if p.Potongan != nil {
		potongan = *p.Potongan
	}
	subtotal := order.GrandTotal - potongan
	var totalProfit int64
	for _, item := range order.OrderItem {
		totalProfit += item.Profit
	}
	orderPay := orderModel.OrderPay{
		OrderID:            p.OrderID,
		MetodePembayaranID: p.MetodePembayaranID,
		UangDibayar:        p.UangDibayar,
		Kembalian:          kembalian,
		Potongan:           &potongan,
		Pajak:              nil,
		SubTotal:           subtotal,
		Total:              res.GrandTotal,
		TotalProfit:        totalProfit,
	}

	sudahBayar, err := s.repoKat.Get(ctx, refStatusBayar, statusBayar["SUDAH_BAYAR"].Desc)
	if err != nil {
		return payModel.PayResponse{}, err
	}
	pendingBayar, err := s.repoKat.Get(ctx, refStatusBayar, statusBayar["PENDING"].Desc)
	if err != nil {
		return payModel.PayResponse{}, err
	}
	isTunai := strings.TrimSpace(bayarID.Deskripsi) == strings.TrimSpace(metodeBayar["TUNAI"].Desc)

	var statusID uuid.UUID
	if isTunai {
		statusID = sudahBayar.ID
	} else {
		statusID = pendingBayar.ID
	}

	// Create sekali saja
	err = s.repo2.CreateOrderPay(ctx, orderPay, statusID)
	if err != nil {
		return payModel.PayResponse{}, err
	}

	// Jika TUNAI, return data order terbaru
	if isTunai {
		updatedOrder, err := s.repo2.GetOrderDataById(ctx, p.OrderID)
		if err != nil {
			return payModel.PayResponse{}, err
		}
		return payModel.PayResponse{
			ID:     &updatedOrder.ID,
			Status: &updatedOrder.Status, // status sudah terupdate karena CreateOrderPay update otomatis
		}, nil
	}
	if res.Status.Nama == statusBayar["PENDING"].Label {
		orderPay, err := s.repo2.GetOrderPayByOrderId(ctx, p.OrderID)
		if err != nil {
			return payModel.PayResponse{}, err
		}
		r := payModel.PayResponse{
			Token:       *orderPay.SnapToken,
			RedirectURL: fmt.Sprintf("%s/snap/v4/redirection/%s", os.Getenv("MIDTRANS_URL"), orderPay.SnapToken),
			Data:        &res,
		}

		return r, nil
	}
	re := mapper.MappingMidtransRequest(list)
	req, err := midtrans.Transaction(re, int(res.GrandTotal), *res.NamaCustomer, "+62812 2045 2410", "kavi.app.26@gmail.com", res.Invoice)
	if err != nil {
		b, err := midtrans.Status(res.Invoice)
		if err != nil {
			return payModel.PayResponse{}, err
		}

		if err := s.Update(ctx, b.Status, res.ID); err != nil {
			return payModel.PayResponse{}, err
		}

		return payModel.PayResponse{Data: &res}, nil
	}

	if err := s.repo.SaveToken(ctx, order.ID, req.Token); err != nil {
		return payModel.PayResponse{}, err
	}

	// req.Data = &res

	return payModel.PayResponse{
		Token:       req.Token,
		RedirectURL: req.RedirectURL,
	}, nil
}
