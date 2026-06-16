package userModel

import (
	kategoriModel "kavi-kasir/internal/model/kategori"
	"time"

	"github.com/google/uuid"
)

type UserCreate struct {
	Username   string    `json:"username"`
	Password   string    `json:"password"`
	Nama       string    `json:"nama"`
	Email      string    `json:"email"`
	NoTelp     string    `json:"no_telp"`
	Foto       string    `json:"foto"`
	KategoriID uuid.UUID `json:"role"`
}
type UserSeed struct {
	Username string `json:"username"`
	Password string `json:"password"`
	Nama     string `json:"nama"`
	Email    string `json:"email"`
	NoTelp   string `json:"no_telp"`
	Role     string `json:"role"`
}

type User struct {
	ID         uuid.UUID              `json:"id" gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	Username   string                 `json:"username" gorm:"type:varchar(255);not null;uniqueIndex"`
	Password   string                 `json:"-" gorm:"type:varchar(255);not null"`
	Nama       string                 `json:"nama" gorm:"type:varchar(80);not null"`
	Foto       string                 `json:"foto" gorm:"type:varchar(255)"`
	Email      string                 `json:"email" gorm:"type:varchar(80);not null;uniqueIndex"`
	NoTelp     string                 `json:"no_telp" gorm:"type:varchar(15);not null"`
	KategoriID uuid.UUID              `json:"role" gorm:"type:uuid;not null"`
	Kategori   kategoriModel.Kategori `json:"kategori" gorm:"foreignKey:KategoriID;constraint:OnDelete:RESTRICT"`
	Saldo      int64                  `json:"saldo" gorm:"default:0"`
	IsDeleted  bool                   `gorm:"default:false" json:"-"`
	CreatedAt  time.Time
	UpdatedAt  time.Time
	// Password   string                 `json:"password" gorm:"type:varchar(255);not null"`
}

type UserPatch struct {
	Username   *string    `json:"username" gorm:"type:varchar(255);not null;unique"`
	Password   *string    `json:"password" gorm:"type:varchar(255);no null"`
	Nama       *string    `json:"nama" gorm:"type:varchar(80);not null"`
	Email      *string    `json:"email" gorm:"type:varchar(80)"`
	NoTelp     *string    `json:"no_telp" gorm:"type:varchar(15)"`
	Foto       *string    `json:"foto" gorm:"type:varchar(255)"`
	KategoriID *uuid.UUID `json:"role" gorm:"type:uuid;not null"`
}

type AccessToken struct {
	ID          uuid.UUID `json:"id" gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	UserID      uuid.UUID `json:"user_id" gorm:"type:uuid;not null"`
	User        User      `json:"user" gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE;"`
	AccessToken string    `json:"access_token" gorm:"type:text;not null"`
	ExpiredAt   time.Time `json:"expired_at" gorm:"not null"`
	CreatedAt   time.Time `json:"-" gorm:"not null;default:now()"`
	UpdatedAt   time.Time `json:"-" gorm:"not null;default:now()"`
}

type Login struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type ResponseToken struct {
	AccessToken string `json:"access_token"`
}

type UserShow struct {
	ID       uuid.UUID `json:"id"`
	Username string    `json:"username"`
	Nama     string    `json:"nama"`
	Email    string    `json:"email"`
	NoTelp   string    `json:"no_telp"`
	Foto     string    `json:"foto"`
	Role     string    `json:"role"`
}
