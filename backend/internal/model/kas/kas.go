package kasModel

import (
	userModel "kavi-kasir/internal/model/user"
	"time"

	"github.com/google/uuid"
)

type Kas struct {
	ID         uuid.UUID      `gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	UserID     uuid.UUID      `gorm:"type:uuid;not null"`
	User       userModel.User `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
	Jumlah     int64          `gorm:"not null"` // positif = masuk, negatif = keluar
	Keterangan string         `gorm:"type:varchar(255)"`
	CreatedAt  time.Time
	UpdatedAt  time.Time
}
