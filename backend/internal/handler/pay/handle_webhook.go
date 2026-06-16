package payHandle

import (
	"context"
	"kavi-kasir/internal/http/helper"
	midtransModel "kavi-kasir/internal/model/midtrans"
	kategoriRepo "kavi-kasir/internal/repository/kategori"
	orderRepo "kavi-kasir/internal/repository/order"
	payRepo "kavi-kasir/internal/repository/pay"
	kategoriService "kavi-kasir/internal/service/kategori"
	payService "kavi-kasir/internal/service/pay"
	"net/http"
	"time"

	"gorm.io/gorm"
)

func HandleWebhook(db *gorm.DB) http.HandlerFunc {

	repo := payRepo.NewPayRepository(db)
	re := orderRepo.NewOrderRepository(db)
	repoKat := kategoriRepo.NewKategoryRepository(db)
	serv := payService.NewPayService(repo, re, repoKat)

	rep := kategoriRepo.NewKategoryRepository(db)
	ser := kategoriService.NewKategoriService(rep)

	return func(w http.ResponseWriter, r *http.Request) {
		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		switch r.Method {
		case http.MethodPost:
			webhook(ctx, serv, ser)(w, r)
		}
	}
}

func webhook(ctx context.Context, serv payService.PayService, ser kategoriService.KategoriService) http.HandlerFunc {
	return helper.Post3(ctx, ser, func(ctx context.Context, data midtransModel.MidtransWebhook) (string, error) {
		if err := serv.MidtransWebhook(ctx, data); err != nil {
			return "failed", err
		}

		return "succes", nil
	})
}
