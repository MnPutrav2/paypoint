package stokService

import (
	stokModel "kavi-kasir/internal/model/stok"
	stokRepo "kavi-kasir/internal/repository/stok"

	"github.com/google/uuid"
)

type StokService interface {
	Update(id uuid.UUID, stok stokModel.StokAdd) (string, error)
}

type stokService struct {
	repo stokRepo.StokRepository
}

func NewProdukService(repo stokRepo.StokRepository) StokService {
	return &stokService{repo: repo}
}
