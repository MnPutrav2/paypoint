package cmd

import (
	"fmt"
	"kavi-kasir/internal/config"
	"kavi-kasir/internal/database"
	authHandle "kavi-kasir/internal/handler/auth"
	bankHandle "kavi-kasir/internal/handler/bank"
	dashboardHandle "kavi-kasir/internal/handler/dashboard"
	katalogHandle "kavi-kasir/internal/handler/katalog"
	kategoriHandle "kavi-kasir/internal/handler/kategori"
	orderHandler "kavi-kasir/internal/handler/order"
	payHandle "kavi-kasir/internal/handler/pay"
	produkHandler "kavi-kasir/internal/handler/produk"
	rekeningHandle "kavi-kasir/internal/handler/rekening"
	stokHandler "kavi-kasir/internal/handler/stok"
	userHandel "kavi-kasir/internal/handler/user"
	authRepo "kavi-kasir/internal/repository/auth"
	bankRepo "kavi-kasir/internal/repository/bank"
	katalogRepo "kavi-kasir/internal/repository/katalog"
	kategoriRepo "kavi-kasir/internal/repository/kategori"
	orderRepo "kavi-kasir/internal/repository/order"
	payRepo "kavi-kasir/internal/repository/pay"
	produkRepo "kavi-kasir/internal/repository/produk"
	rekeningRepo "kavi-kasir/internal/repository/rekening"
	rekomendasiRepo "kavi-kasir/internal/repository/rekomendasi"
	stokRepo "kavi-kasir/internal/repository/stok"
	userRepo "kavi-kasir/internal/repository/user"
	authService "kavi-kasir/internal/service/auth"
	bankService "kavi-kasir/internal/service/bank"
	dashboardService "kavi-kasir/internal/service/dashboard"
	katalogService "kavi-kasir/internal/service/katalog"
	kategoriService "kavi-kasir/internal/service/kategori"
	orderService "kavi-kasir/internal/service/order"
	payService "kavi-kasir/internal/service/pay"
	produkService "kavi-kasir/internal/service/produk"
	rekeningService "kavi-kasir/internal/service/rekening"
	stokService "kavi-kasir/internal/service/stok"
	userService "kavi-kasir/internal/service/user"
	"kavi-kasir/pkg/enc"
	"kavi-kasir/pkg/middleware"
	"kavi-kasir/pkg/response"
	"net/http"
	"os"

	_ "kavi-kasir/docs"

	"time"

	httpSwagger "github.com/swaggo/http-swagger"
)

func Server(listen string) {
	db, err := config.InitDB()
	if err != nil {
		panic(err)
	}

	if err := database.Migrate(db); err != nil {
		panic(err)
	}

	// Route
	http.Handle("/", httpSwagger.WrapHandler)

	// auth handler
	http.HandleFunc("/enc", func(w http.ResponseWriter, r *http.Request) {
		result, err := enc.EncryptPayload(r.Body, os.Getenv("INI_DIGINIIN"))
		if err != nil {
			response.Message("enc error", err.Error(), "WARN", 400, w, r)
			return
		}

		response.Message(result, "success", "INFO", 200, w, r)
	})

	mux := http.NewServeMux()

	authRepo := authRepo.NewAuthRepository(db)
	bankRepo := bankRepo.NewBankRepository(db)
	kategoriRepo := kategoriRepo.NewKategoryRepository(db)
	produkRepo := produkRepo.NewProdukRepository(db)
	katalogRepo := katalogRepo.NewKatalogRepository(db)
	stokRepo := stokRepo.NewStokRepository(db)
	orderRepo := orderRepo.NewOrderRepository(db)
	rekRepo := rekeningRepo.NewRekeningRepository(db)
	userRepo := userRepo.NewUserRepository(db)
	payRepo := payRepo.NewPayRepository(db)
	rekomRepo := rekomendasiRepo.NewRekomendasiRepo(db)

	authServ := authService.NewAuthService(authRepo)
	bankServ := bankService.NewBankService(bankRepo)
	kategoriServ := kategoriService.NewKategoriService(kategoriRepo)
	produkServ := produkService.NewProdukService(produkRepo)
	katalogServ := katalogService.NewKatalogService(katalogRepo, produkRepo)
	stokServ := stokService.NewProdukService(stokRepo)
	orderServ := orderService.NewOrderService(orderRepo, katalogRepo, stokRepo, kategoriRepo, userRepo)
	rekServ := rekeningService.NewRekeningService(rekRepo)
	userServ := userService.NewUserService(userRepo)
	payServ := payService.NewPayService(payRepo, orderRepo, kategoriRepo)

	dashboardServ := dashboardService.NewDashboardService(userRepo, orderRepo, rekomRepo)
	// Buat helper untuk mengurangi repetisi middleware.Chain
	// chain := func(h http.Handler, middlewares ...func(http.Handler) http.Handler) http.Handler {
	// 	return middleware.Chain(h, middlewares...)
	// }
	// authOnly := func(h http.HandlerFunc) http.HandlerFunc {
	// 	return middleware.Chain(h, middleware.Authorization2, middleware.CORS)
	// }
	// withReference := func(h http.HandlerFunc) http.HandlerFunc {
	// 	return middleware.Chain(h, middleware.ReferenceMiddleware(kategoriServ), middleware.CORS)
	// }
	// withCORS := func(h http.HandlerFunc) http.HandlerFunc {
	// 	return middleware.Chain(h, middleware.CORS)
	// }
	// authWithRef := func(h http.HandlerFunc) http.HandlerFunc {
	// 	return middleware.Chain(h, middleware.Authorization2, middleware.ReferenceMiddleware(kategoriServ), middleware.CORS)
	// }

	authOnly := func(h http.HandlerFunc) http.HandlerFunc {
		return middleware.Chain(
			h,
			middleware.Authorization2,
		)
	}

	authWithRef := func(h http.HandlerFunc) http.HandlerFunc {
		return middleware.Chain(
			h,
			middleware.Authorization2,
			middleware.ReferenceMiddleware(kategoriServ),
		)
	}

	// Auth — tanpa Authorization2
	mux.HandleFunc("POST    /auth/login", authHandle.Login(authServ))
	mux.HandleFunc("POST    /auth/register", authHandle.Register(authServ))
	// mux.HandleFunc("OPTIONS    /auth/login", middleware.Chain(authHandle.Login(authServ), middleware.CORS))
	// mux.HandleFunc("OPTIONS    /auth/register", middleware.Chain(authHandle.Register(authServ), middleware.CORS))

	// Bank
	mux.HandleFunc("GET     /bank/{id}", authOnly(bankHandle.GetByID(bankServ)))
	mux.HandleFunc("DELETE  /bank/{id}", authOnly(bankHandle.Delete(bankServ)))
	mux.HandleFunc("PUT     /bank/{id}", authOnly(bankHandle.Put(bankServ)))
	mux.HandleFunc("POST    /bank", authOnly(bankHandle.Post(bankServ)))
	mux.HandleFunc("GET     /bank", authOnly(bankHandle.Get(bankServ)))

	// Dashboard
	mux.HandleFunc("GET     /dashboard", authWithRef(dashboardHandle.Get(dashboardServ)))

	// Kategori
	mux.HandleFunc("GET     /kategori", authOnly(kategoriHandle.Get(kategoriServ)))
	mux.HandleFunc("POST    /kategori", authOnly(kategoriHandle.Post(kategoriServ)))
	mux.HandleFunc("DELETE  /kategori/{id}", authOnly(kategoriHandle.Delete(kategoriServ)))
	mux.HandleFunc("PUT     /kategori/{id}", authOnly(kategoriHandle.Update(kategoriServ)))

	// Ref Kategori
	mux.HandleFunc("GET     /ref-kategori", authOnly(kategoriHandle.GetRef(kategoriServ)))
	mux.HandleFunc("POST    /ref-kategori", authOnly(kategoriHandle.PostRef(kategoriServ)))
	mux.HandleFunc("DELETE  /ref-kategori/{id}", authOnly(kategoriHandle.DeleteRef(kategoriServ)))
	mux.HandleFunc("PUT     /ref-kategori/{id}", authOnly(kategoriHandle.UpdateRef(kategoriServ)))
	mux.HandleFunc("GET     /reference/refresh", authOnly(kategoriHandle.Refresh(kategoriServ)))

	// Produk
	mux.HandleFunc("GET     /produk", authOnly(produkHandler.Get(produkServ, kategoriServ)))
	mux.HandleFunc("GET     /produk/{id}", authOnly(produkHandler.GetByID(produkServ, kategoriServ)))
	mux.HandleFunc("POST    /produk", authOnly(produkHandler.Post(produkServ)))
	mux.HandleFunc("DELETE  /produk/{id}", authOnly(produkHandler.Delete(produkServ, kategoriServ)))
	mux.HandleFunc("PATCH   /produk/{id}", authOnly(produkHandler.Patch(produkServ)))
	mux.HandleFunc("PUT     /produk/{id}", authOnly(produkHandler.Put(produkServ, kategoriServ)))

	// Katalog
	mux.HandleFunc("GET     /katalog", authOnly(katalogHandle.Get(katalogServ, kategoriServ)))
	mux.HandleFunc("GET     /katalog/{id}", authOnly(katalogHandle.GetByID(katalogServ, kategoriServ)))
	mux.HandleFunc("DELETE  /katalog/{id}", authOnly(katalogHandle.Delete(katalogServ, kategoriServ)))
	mux.HandleFunc("PATCH   /katalog/{id}", authOnly(katalogHandle.Patch(katalogServ, kategoriServ)))
	mux.HandleFunc("POST    /katalog", authOnly(katalogHandle.Create(katalogServ, kategoriServ)))

	// Stok
	mux.HandleFunc("PATCH   /stok/{id}", authOnly(stokHandler.Patch(stokServ)))

	// Order
	mux.HandleFunc("GET     /order", authOnly(orderHandler.Get(orderServ, kategoriServ)))
	mux.HandleFunc("GET     /order/grafik_omzet", authWithRef(orderHandler.GetGrafikOmzet(orderServ)))
	mux.HandleFunc("GET     /order/grafik_item_terlaris", authWithRef(orderHandler.GetGrafikItemTerlaris(orderServ)))
	mux.HandleFunc("GET     /order/{id}", authOnly(orderHandler.GetPage(orderServ, kategoriServ)))
	mux.HandleFunc("POST    /order", authOnly(orderHandler.Post(orderServ, kategoriServ)))
	mux.HandleFunc("DELETE  /order/{id}", authOnly(orderHandler.Delete(orderServ, kategoriServ)))
	mux.HandleFunc("PATCH   /order/{id}", authOnly(orderHandler.Update(orderServ, kategoriServ)))
	// mux.HandleFunc("PATCH /order/generate-license", authOnly(orderHandler.Update(orderServ, kategoriServ)))

	// Rekening
	mux.HandleFunc("GET     /rekening", authOnly(rekeningHandle.Get(rekServ, kategoriServ)))
	mux.HandleFunc("GET     /rekening/{id}", authOnly(rekeningHandle.GetByID(rekServ, kategoriServ)))
	mux.HandleFunc("POST    /rekening", authOnly(rekeningHandle.Post(rekServ, kategoriServ)))
	mux.HandleFunc("DELETE  /rekening/{id}", authOnly(rekeningHandle.Delete(rekServ, kategoriServ)))
	mux.HandleFunc("PUT     /rekening/{id}", authOnly(rekeningHandle.Patch(rekServ, kategoriServ)))

	// Users
	mux.HandleFunc("GET     /users", authOnly(userHandel.GetAll(userServ, kategoriServ)))
	mux.HandleFunc("GET     /users/{id}", authOnly(userHandel.Get(userServ)))
	mux.HandleFunc("PATCH   /users/{id}", authOnly(userHandel.Patch(userServ)))
	mux.HandleFunc("DELETE  /users/{id}", authOnly(userHandel.Delete(userServ)))

	// Bayar
	mux.HandleFunc("POST    /bayar", authOnly(payHandle.Create(payServ, kategoriServ)))
	mux.HandleFunc("POST    /notification", middleware.Chain(payHandle.Webhook(payServ, kategoriServ)))

	fmt.Println("✅  Server start in : ", time.Now().Format("2006-01-02 15:04:05"))
	fmt.Println("✅  Database connected")
	fmt.Println("✅  Migrate Success")
	fmt.Println("-- Server listen in port ", listen, " --")

	backendMux := http.NewServeMux()
	handler := middleware.CORSHandler(
		http.StripPrefix("/backend", mux),
	)
	// backendMux.Handle("/backend/", http.StripPrefix("/backend", mux))

	backendMux.Handle("/backend/", handler)
	http.ListenAndServe(listen, backendMux)
}
