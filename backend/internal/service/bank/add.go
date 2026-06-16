package bankService

import (
	"context"
	"errors"
	bankModel "kavi-kasir/internal/model/bank"

	"github.com/jackc/pgx/v5/pgconn"
)

func (s *bankService) AddBankService(ctx context.Context, req *bankModel.Bank) (bankModel.Bank, string, int, error) {
	result, err := s.repo.AddBank(ctx, req)
	if err != nil {

		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) {
			if pgErr.Code == "23505" {
				return bankModel.Bank{}, "bank sudah ada", 400, err
			}
		}

		return bankModel.Bank{}, "failed create data", 400, err
	}

	return result, "success", 201, nil
}
