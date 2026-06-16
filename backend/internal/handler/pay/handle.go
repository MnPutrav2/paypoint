package payHandle

import (
	"context"
	"kavi-kasir/internal/http/helper"
	midtransModel "kavi-kasir/internal/model/midtrans"
	payModel "kavi-kasir/internal/model/pay"
	kategoriService "kavi-kasir/internal/service/kategori"
	payService "kavi-kasir/internal/service/pay"
	"net/http"
	"time"
)

func Create(serv payService.PayService, ser kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		helper.Post4(ctx, w, r, ser, func(ctx context.Context, data payModel.PayRequest) (payModel.PayResponse, error) {
			result, err := serv.CreatePayment(ctx, data)
			if err != nil {
				return payModel.PayResponse{}, err
			}

			return result, nil
		})
	}
}

func Webhook(serv payService.PayService, ser kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		helper.Post4(ctx, w, r, ser, func(ctx context.Context, data midtransModel.MidtransWebhook) (string, error) {
			if err := serv.MidtransWebhook(ctx, data); err != nil {
				return "failed", err
			}

			return "succes", nil
		})
	}
}
