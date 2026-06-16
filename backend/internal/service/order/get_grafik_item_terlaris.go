package orderService

import (
	"context"
	dashboardModel "kavi-kasir/internal/model/dashboard"
	utilConst "kavi-kasir/pkg/util/const"
)

// Semua query jalan paralel — lebih cepat
func (s *orderService) GetGrafikItemTerlaris(ctx context.Context, mode utilConst.GrafikMode) ([]dashboardModel.Grafik, error) {
	// userID := ctx.Value(utilConst.ContextUserID).(*jwtEnc.Claims).UserID

	from, to := utilConst.GetDateRange(mode)

	type result[T any] struct {
		val T
		err error
	}

	grafikOmzetCh := make(chan result[[]dashboardModel.Grafik], 1)

	go func() {
		v, err := s.repo.GetGrafikItemTerlaris(ctx, from, to)
		grafikOmzetCh <- result[[]dashboardModel.Grafik]{v, err}
	}()

	grafikOmzet := <-grafikOmzetCh

	// cek semua error
	for _, err := range []error{
		grafikOmzet.err,
	} {
		if err != nil {
			return []dashboardModel.Grafik{}, err
		}
	}

	return grafikOmzet.val, nil
}
