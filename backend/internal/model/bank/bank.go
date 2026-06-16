package bankModel

import (
	"time"

	"github.com/google/uuid"
)

type Bank struct {
	ID        uuid.UUID `json:"id" gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	KodeBank  string    `json:"kode_bank" gorm:"type:varchar(3);not null"`
	Nama      string    `json:"nama" gorm:"type:varchar(255);not null"`
	CreatedAt time.Time `json:"-" gorm:"not null;default:now()"`
	UpdatedAt time.Time `json:"-" gorm:"not null;default:now()"`
}

type BankShow struct {
	ID       uuid.UUID `json:"id"`
	KodeBank string    `json:"kode_bank"`
	Nama     string    `json:"nama"`
}

type BankUpdate struct {
	KodeBank string `json:"kode_bank"`
	Nama     string `json:"nama" gorm:"type:varchar(255);not null"`
}

type BankPatch struct {
	Nama     *string `json:"nama" gorm:"type:varchar(255);not null"`
	KodeBank *string `json:"kode_bank"`
}
