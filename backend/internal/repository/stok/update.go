package stokRepo

import (
	katalogModel "kavi-kasir/internal/model/katalog"
	stokModel "kavi-kasir/internal/model/stok"

	"github.com/google/uuid"
)

func (q *stokRepository) UpdateStok(id uuid.UUID, stok stokModel.StokAdd) error {

	var ix katalogModel.Katalog

	if err := q.db.Model(&katalogModel.Katalog{}).Where("id = ?", id).Find(&ix).Error; err != nil {
		return err
	}

	if err := q.db.Model(&stokModel.Stok{}).Where("produk_id = ?", ix.ProdukID).Update("stok", stok.Stok).Error; err != nil {
		return err
	}

	return nil
}
