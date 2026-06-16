package dashboardHandle

import (
	"kavi-kasir/internal/http/helper"
	dashboardModel "kavi-kasir/internal/model/dashboard"
	dashboardService "kavi-kasir/internal/service/dashboard"
	"net/http"

	"github.com/google/uuid"
)

// @Summary      Menampilkan data mix untuk dashboard
// @Description Menampilkan data mix untuk dashboard
// @Tags         mix untuk dashboard
// @Accept       json
// @Produce      json
// @Success      200 {object} model.Dashboard
// @Router       /dashboard [get]
func Get(serv dashboardService.DashboardService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		req, cancel := helper.NewRequest(w, r)
		defer cancel()

		helper.WithReference(req, func(_ uuid.UUID) (dashboardModel.Dashboard, error) {
			return serv.GetDashboard(req.R.Context(), "minggu")
		})
	}
}
