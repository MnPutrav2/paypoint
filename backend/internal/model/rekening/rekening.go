package rekeningModel

import (
	bankModel "kavi-kasir/internal/model/bank"
	userModel "kavi-kasir/internal/model/user"
	"time"

	"github.com/google/uuid"
)

type Rekening struct {
	ID            uuid.UUID      `json:"id" gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	Nama          string         `json:"nama" gorm:"type:varchar(255);not null"`
	NomorRekening string         `json:"nomor_rekening" gorm:"type:varchar(255);not null"`
	BankID        uuid.UUID      `json:"bank_id" gorm:"type:uuid;not null"`
	Bank          bankModel.Bank `json:"bank" gorm:"foreignKey:BankID;constraint:OnDelete:CASCADE;"`
	UserID        uuid.UUID      `json:"user_id" gorm:"type:uuid;not null"`
	User          userModel.User `json:"user" gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE;"`
	Saldo         int            `json:"saldo" gorm:"type:decimal"`
	CreatedAt     time.Time      `json:"-" gorm:"not null;default:now()"`
	UpdatedAt     time.Time      `json:"-" gorm:"not null;default:now()"`
}

type RekeningShow struct {
	ID            uuid.UUID          `json:"id"`
	Nama          string             `json:"nama"`
	NomorRekening string             `json:"nomor_rekening"`
	Bank          bankModel.BankShow `json:"bank"`
	Saldo         int                `json:"saldo"`
}

type RekeningSaldo struct {
	Saldo int    `json:"saldo"`
	Type  string `json:"type"`
}
