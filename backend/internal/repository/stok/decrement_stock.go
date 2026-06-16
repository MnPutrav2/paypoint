package stokRepo

import (
	stokModel "kavi-kasir/internal/model/stok"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

func (q *stokRepository) DecrementStok(id uuid.UUID, stok int) error {

	if err := q.db.Model(&stokModel.Stok{}).Where("produk_id = ?", id).Update("stok", gorm.Expr("stok - ?", stok)).Error; err != nil {
		return err
	}

	return nil
}
