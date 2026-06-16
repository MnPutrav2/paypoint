package stokService

import (
	"errors"
	stokModel "kavi-kasir/internal/model/stok"

	"github.com/google/uuid"
)

func (s *stokService) Update(id uuid.UUID, stok stokModel.StokAdd) (string, error) {

	switch stok.Tipe {
	case "tambah":
		if err := s.repo.UpdateStokData(id, stok); err != nil {
			return "failed add stock", err
		}
	case "ubah":
		if err := s.repo.UpdateStok(id, stok); err != nil {
			return "failed add stock", err
		}
	default:
		return "change type invalid", errors.New("change type invalid")
	}

	return "success", nil
}
