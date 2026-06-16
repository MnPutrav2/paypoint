package orderHandler

import (
	"context"
	"kavi-kasir/internal/http/helper"
	"kavi-kasir/internal/mapper"
	orderModel "kavi-kasir/internal/model/order"
	katalogRepo "kavi-kasir/internal/repository/katalog"
	kategoriRepo "kavi-kasir/internal/repository/kategori"
	orderRepo "kavi-kasir/internal/repository/order"
	stokRepo "kavi-kasir/internal/repository/stok"
	userRepo "kavi-kasir/internal/repository/user"
	kategoriService "kavi-kasir/internal/service/kategori"
	orderService "kavi-kasir/internal/service/order"
	"net/http"
	"strconv"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Prefix handler, Example {path}/produk/{produk_id}
func HandlerProdukPrefix(db *gorm.DB) http.HandlerFunc {

	repo := orderRepo.NewOrderRepository(db)
	stok := stokRepo.NewStokRepository(db)
	katalog := katalogRepo.NewKatalogRepository(db)
	ref := kategoriRepo.NewKategoryRepository(db)
	user := userRepo.NewUserRepository(db)
	serv := orderService.NewOrderService(repo, katalog, stok, ref, user)

	rep := kategoriRepo.NewKategoryRepository(db)
	ser := kategoriService.NewKategoriService(rep)

	return func(w http.ResponseWriter, r *http.Request) {
		ctx, close := context.WithTimeout(r.Context(), time.Second*5)
		defer close()

		switch r.Method {
		case http.MethodGet:
			getOrder(ctx, serv, ser)(w, r)
		case http.MethodDelete:
			deleteOrder(ctx, serv, ser)(w, r)
		case http.MethodPatch:
			updateOrder(ctx, serv, ser)(w, r)
		}
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
func getOrder(ctx context.Context, serv orderService.OrderService, ser kategoriService.KategoriService) http.HandlerFunc {
	return helper.Get2(ctx, "/order/", ser, func(ctx context.Context, id uuid.UUID) ([]orderModel.OrderItemShow, error) {
		result, err := serv.GetByID(ctx, id)
		if err != nil {
			return nil, err
		}

		return mapper.MappingSliceOrder(result), nil
	})
}

// @Summary      Hapus order
// @Description hapus order
// @Tags         order
// @Accept       json
// @Produce      json
// @Param        order_id path string true "order_id"
// @Success      200 {object} produkModel.Produk
// @Router       /order/{order_id} [delete]
func deleteOrder(ctx context.Context, serv orderService.OrderService, ser kategoriService.KategoriService) http.HandlerFunc {
	return helper.Delete2(ctx, "/order/", ser, func(ctx context.Context, id, user uuid.UUID) error {
		if err := serv.Delete(ctx, id); err != nil {
			return err
		}

		return nil
	})
}

// @Summary      Update status order
// @Description update status order
// @Tags         order
// @Accept       json
// @Produce      json
// @Param        order_id path string true "order_id"
// @Param        body body orderModel.OrderSetStatus true "Field order"
// @Success      200 {object} orderModel.OrderItemResult
// @Router       /order/{order_id} [patch]
func updateOrder(ctx context.Context, serv orderService.OrderService, ser kategoriService.KategoriService) http.HandlerFunc {
	return helper.Update2(ctx, "/order/", ser, func(ctx context.Context, id, user uuid.UUID, body orderModel.OrderSetStatus) (orderModel.OrderItemResult, error) {
		u := strconv.Itoa(body.Status)
		result, err := serv.UpdateOrder(ctx, id, u)
		if err != nil {
			return orderModel.OrderItemResult{}, err
		}

		return mapper.MappingSingleOrderList(result), nil
	})
}
