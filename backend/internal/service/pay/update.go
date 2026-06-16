package payService

import (
	"context"

	"github.com/google/uuid"
)

func (s *payService) Update(ctx context.Context, status string, id uuid.UUID) error {
	switch status {
	case "settlement":
		ka, err := s.repo2.GetKategori(ctx, "4")
		if err != nil {
			return err
		}

		if _, err := s.repo2.UpdateOrder(ctx, id, ka.ID); err != nil {
			return err
		}
	case "expire":
		ka, err := s.repo2.GetKategori(ctx, "6")
		if err != nil {
			return err
		}

		if _, err := s.repo2.UpdateOrder(ctx, id, ka.ID); err != nil {
			return err
		}
	case "pending":
		ka, err := s.repo2.GetKategori(ctx, "7")
		if err != nil {
			return err
		}

		if _, err := s.repo2.UpdateOrder(ctx, id, ka.ID); err != nil {
			return err
		}
	case "cancel":
		ka, err := s.repo2.GetKategori(ctx, "1")
		if err != nil {
			return err
		}

		if _, err := s.repo2.UpdateOrder(ctx, id, ka.ID); err != nil {
			return err
		}
	}

	return nil
}
