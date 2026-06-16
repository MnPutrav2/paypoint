package stokRepo

import (
	"errors"
	katalogModel "kavi-kasir/internal/model/katalog"
	stokModel "kavi-kasir/internal/model/stok"

	"github.com/google/uuid"
)

func (q *stokRepository) CheckStock(id uuid.UUID, stok int) error {
	var (
		i  int64
		ix katalogModel.Katalog
	)

	if err := q.db.Model(&katalogModel.Katalog{}).Where("id = ?", id).Find(&ix).Error; err != nil {
		return err
	}

	if err := q.db.Model(&stokModel.Stok{}).Where("produk_id = ?", ix.ProdukID).Where("stok > ?", stok).Count(&i).Error; err != nil {
		return err
	}

	if i == 0 {
		return errors.New("stok tidak cukup")
	}

	return nil
}
