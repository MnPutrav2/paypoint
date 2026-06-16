package errorhttp

import (
	"context"
	"errors"
	"net/http"

	"github.com/jackc/pgx/v5/pgconn"
	"gorm.io/gorm"
)

var (
	ErrForbidden            = errors.New("anda tidak diizinkan mengakses resource ini")
	ErrKatalogPrice         = errors.New("harga katalog tidak boleh lebih kecil dari harga produk")
	ErrAvailableData        = errors.New("data sudah ada")
	ErrUpdateData           = errors.New("gagal mengupdate data")
	ErrDeleteUser           = errors.New("gagal menghapus user")
	ErrAccountNotRegistered = errors.New("akun belum terdaftar")
	ErrAccountNotFound      = errors.New("akun tidak ditemukan")
	ErrUsernameOrPassword   = errors.New("username atau password salah")
	ErrGenerateToken        = errors.New("error generate token")
	ErrTimeRefLast          = errors.New("reference-last harus berformat waktu YYYY-MM-DD HH:MM:SS")
	ErrGetRefLast           = errors.New("gagal mengambil data reference")
	ErrOrder                = errors.New("transaksi sudah dibatalkan")
	ErrDeleteRek            = errors.New("gagal menghapus rekening, saldo harus 0")
	ErrRek                  = errors.New("rekening tidak sesuai")
	ErrPriceKat             = errors.New("harga katalog tidak boleh kecil dari harga produk")
	ErrOrderPri             = errors.New("harga total tidak sesuai")
	ErrStock                = errors.New("stok tidak cukup")
	ErrTrxId                = errors.New("transaction_details.order_id sudah digunakan")
)

func Map(err error) (string, int) {
	switch {
	case errors.Is(err, ErrTrxId):
		return "transaction_details.order_id sudah digunakan", http.StatusBadRequest

	case errors.Is(err, ErrStock):
		return "stok tidak cukup", http.StatusBadRequest

	case errors.Is(err, ErrOrderPri):
		return "harga total tidak sesuai", http.StatusBadRequest

	case errors.Is(err, ErrPriceKat):
		return "harga katalog tidak boleh kecil dari harga produk", http.StatusBadRequest

	case errors.Is(err, ErrRek):
		return "rekening tidak sesuai", http.StatusBadRequest

	case errors.Is(err, ErrDeleteRek):
		return "gagal menghapus rekening, saldo harus 0", http.StatusBadRequest

	case errors.Is(err, ErrOrder):
		return "transaksi sudah dibatalkan", http.StatusBadRequest

	case errors.Is(err, ErrForbidden):
		return "anda tidak diizinkan mengakses resource ini", http.StatusForbidden

	case errors.Is(err, ErrKatalogPrice):
		return "harga katalog tidak boleh lebih kecil dari harga produk", http.StatusBadRequest

	case errors.Is(err, ErrAvailableData):
		return "data sudah ada", http.StatusBadRequest

	case errors.Is(err, ErrTimeRefLast):
		return "header reference-last tidak boleh kosong", http.StatusBadRequest

	case errors.Is(err, ErrGetRefLast):
		return "gagal mengambil data reference", http.StatusBadRequest

	case errors.Is(err, ErrUpdateData):
		return "gagal mengupdate data", http.StatusBadRequest

	case errors.Is(err, ErrDeleteUser):
		return "gagal menghapus data", http.StatusBadRequest

	case errors.Is(err, ErrUsernameOrPassword):
		return "username atau password salah", http.StatusBadRequest

	case errors.Is(err, ErrAccountNotRegistered):
		return "akun belum terdaftar", http.StatusBadRequest

	case errors.Is(err, ErrAccountNotFound):
		return "akun tidak ditemukan", http.StatusNotFound

	case errors.Is(err, ErrGenerateToken):
		return "error generate token", http.StatusInternalServerError

	case errors.Is(err, context.DeadlineExceeded):
		return "request time out", http.StatusRequestTimeout

	case errors.Is(err, gorm.ErrDuplicatedKey):
		return "duplicate entry", http.StatusBadRequest

	default:
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) {
			switch pgErr.Code {
			case "23505":
				return "duplicate entry", http.StatusBadRequest
			}
		}

		return "failed", http.StatusBadRequest
	}
}
