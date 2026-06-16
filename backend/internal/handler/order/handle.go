package orderHandler

import (
	"context"
	"kavi-kasir/internal/http/helper"
	"kavi-kasir/internal/mapper"
	dashboardModel "kavi-kasir/internal/model/dashboard"
	orderModel "kavi-kasir/internal/model/order"
	kategoriService "kavi-kasir/internal/service/kategori"
	orderService "kavi-kasir/internal/service/order"
	jwtEnc "kavi-kasir/pkg/auth/jwt"
	utilConst "kavi-kasir/pkg/util/const"
	"net/http"
	"strconv"
	"time"

	"github.com/google/uuid"
)

// @Summary      Menampilkan order list
// @Description Menampilkan order list
// @Tags         order
// @Accept       json
// @Produce      json
// @Param        page path int false "page"
// @Param        size path int false "size"
// @Param        keyword path string false "keyword"
// @Success      200 {object} []orderModel.Order
// @Router       /order [get]
func Get(serv orderService.OrderService, ser kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		helper.Paginated3(ctx, w, r, ser, func(ctx context.Context, offsite, size int, keyword string, sortColumn string, sortDirection string) (any, int, error) {
			result, total, err := serv.GetAllPaginated(ctx, offsite, size, keyword, sortColumn, sortDirection)
			if err != nil {
				return nil, 0, err
			}

			return mapper.MappingSliceOrderList(result), total, nil
		})
	}
}

// @Summary      Menambahkan order
// @Description Menambahkan order
// @Tags         order
// @Accept       json
// @Produce      json
// @Param        body body []orderModel.OrderAdd true "Field order"
// @Success      200 {object} model.ResponseMessage
// @Router       /order [post]
func Post(serv orderService.OrderService, ser kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		c := ctx.Value(utilConst.ContextUserID).(*jwtEnc.Claims)
		helper.Post4(ctx, w, r, ser, func(ctx context.Context, data orderModel.OrderAdd) (orderModel.OrderItemResult, error) {
			result, err := serv.Create(ctx, data, c.UserID, data.Total)
			if err != nil {
				return orderModel.OrderItemResult{}, err
			}

			ma := mapper.MappingSingleOrderList(result)
			return ma, nil
		})
	}
}

// @Summary      Mendapatkan list order berdasarkan id
// @Description Order
// @Tags         order
// @Accept       json
// @Produce      json
// @Param        order_id path string true "order_id"
// @Success      200 {object} []orderModel.OrderListShow
// @Router       /order/{order_id} [get]
func GetPage(serv orderService.OrderService, ser kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		helper.Get3(ctx, "/order/", ser, w, r, func(ctx context.Context, id uuid.UUID) ([]orderModel.OrderItemShow, error) {
			result, err := serv.GetByID(ctx, id)
			if err != nil {
				return nil, err
			}

			return mapper.MappingSliceOrder(result), nil
		})
	}
}

// @Summary      Mendapatkan data grafik omzet order
// @Description  Grafik Omzet Order
// @Tags         grafik omzet order
// @Accept       json
// @Produce      json
// @Param        mode path string true "mode"
// @Success      200 {object} []Grafik
// @Router       /order/grafik_omzet [get]
func GetGrafikOmzet(serv orderService.OrderService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		req, cancel := helper.NewRequest(w, r)
		defer cancel()

		mode := utilConst.GrafikMode(r.URL.Query().Get("mode"))
		if mode == "" {
			mode = utilConst.GrafikMinggu
		}
		helper.WithReference(req, func(_ uuid.UUID) ([]dashboardModel.Grafik, error) {
			return serv.GetGrafikOmzet(req.R.Context(), mode)
		})
	}
}

// @Summary      Mendapatkan data grafik item terlaris
// @Description  Grafik Item terlaris
// @Tags         grafik item terlaris
// @Accept       json
// @Produce      json
// @Param        mode path string true "mode"
// @Success      200 {object} []Grafik
// @Router       /order/grafik_item_terlaris [get]
func GetGrafikItemTerlaris(serv orderService.OrderService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		req, cancel := helper.NewRequest(w, r)
		defer cancel()

		mode := utilConst.GrafikMode(r.URL.Query().Get("mode"))
		if mode == "" {
			mode = utilConst.GrafikMinggu
		}
		helper.WithReference(req, func(_ uuid.UUID) ([]dashboardModel.Grafik, error) {
			return serv.GetGrafikItemTerlaris(req.R.Context(), mode)
		})
	}
}

// @Summary      Hapus order
// @Description hapus order
// @Tags         order
// @Accept       json
// @Produce      json
// @Param        order_id path string true "order_id"
// @Success      200 {object} produkModel.Produk
// @Router       /order/{order_id} [delete]
func Delete(serv orderService.OrderService, ser kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		c := ctx.Value(utilConst.ContextUserID).(*jwtEnc.Claims)
		helper.Delete3(ctx, "/order/", w, r, ser, c, func(ctx context.Context, id, _ uuid.UUID) error {
			if err := serv.Delete(ctx, id); err != nil {
				return err
			}

			return nil
		})
	}
}

// @Summary      Update status order
// @Description update status order
// @Tags         order
// @Accept       json
// @Produce      json
// @Param        order_id path string true "order_id"
// @Param        body body orderModel.OrderSetStatus true "Field order"
// @Success      200 {object} orderModel.OrderListResult
// @Router       /order/{order_id} [put]
func Update(serv orderService.OrderService, ser kategoriService.KategoriService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		c := ctx.Value(utilConst.ContextUserID).(*jwtEnc.Claims)
		helper.Update3(ctx, "/order/", w, r, ser, c, func(ctx context.Context, id, user uuid.UUID, body orderModel.OrderSetStatus) (orderModel.OrderItemResult, error) {
			u := strconv.Itoa(body.Status)
			result, err := serv.UpdateOrder(ctx, id, u)
			if err != nil {
				return orderModel.OrderItemResult{}, err
			}

			return mapper.MappingSingleOrderList(result), nil
		})
	}
}

// @Summary      Update status order untuk generate license
// @Description update status order untuk generate license
// @Tags         order - generate license
// @Accept       json
// @Produce      json
// @Param        order_id path string true "order_id"
// @Param        body body orderModel.OrderSetStatus true "Field order"
// @Success      200 {object} orderModel.OrderListResult
// @Router       /order/generate-license [patch]
// func GenerateLicense(serv orderService.OrderService, ser kategoriService.KategoriService) http.HandlerFunc {
// 	return func(w http.ResponseWriter, r *http.Request) {
// 		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
// 		defer close()

// 		c := ctx.Value(utilConst.ContextUserID).(*jwtEnc.Claims)
// 		helper.Update3(ctx, "/order/generate-license", w, r, ser, c, func(ctx context.Context, id, user uuid.UUID, body orderModel.OrderSetStatus) (orderModel.OrderItemResult, error) {
// 			result, err := serv.GenerateLicense(ctx, id)
// 			if err != nil {
// 				return orderModel.OrderItemResult{}, err
// 			}

// 			return mapper.MappingSingleOrderList(result), nil
// 		})
// 	}
// }
