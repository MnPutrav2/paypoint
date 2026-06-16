package payService

import (
	"context"
	midtransModel "kavi-kasir/internal/model/midtrans"
)

func (s *payService) MidtransWebhook(ctx context.Context, body midtransModel.MidtransWebhook) error {

	res, err := s.repo2.GetByInvoice(ctx, body.OrderID)
	if err != nil {
		return err
	}

	switch body.TransactionStatus {
	case "settlement":
		ka, err := s.repo2.GetKategori(ctx, "4")
		if err != nil {
			return err
		}

		if _, err := s.repo2.UpdateOrder(ctx, res.ID, ka.ID); err != nil {
			return err
		}
	case "expire":
		ka, err := s.repo2.GetKategori(ctx, "6")
		if err != nil {
			return err
		}

		if _, err := s.repo2.UpdateOrder(ctx, res.ID, ka.ID); err != nil {
			return err
		}
	case "pending":
		ka, err := s.repo2.GetKategori(ctx, "7")
		if err != nil {
			return err
		}

		if _, err := s.repo2.UpdateOrder(ctx, res.ID, ka.ID); err != nil {
			return err
		}
	case "cancel":
		ka, err := s.repo2.GetKategori(ctx, "1")
		if err != nil {
			return err
		}

		if _, err := s.repo2.UpdateOrder(ctx, res.ID, ka.ID); err != nil {
			return err
		}
	}

	return nil
}
