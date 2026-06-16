package stokRepo

import (
	stokModel "kavi-kasir/internal/model/stok"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

func (q *stokRepository) UpdateStokData(id uuid.UUID, stok stokModel.StokAdd) error {

	if err := q.db.
		Model(&stokModel.Stok{}).Where("produk_id = ?", id).Update("stok", gorm.Expr("stok + ?", stok.Stok)).Error; err != nil {
		return err
	}

	return nil
}
