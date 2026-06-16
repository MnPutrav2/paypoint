package authModel

import (
	userModel "kavi-kasir/internal/model/user"
	"time"

	"github.com/google/uuid"
)

type AccessToken struct {
	ID          uuid.UUID      `json:"id" gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	UserID      uuid.UUID      `json:"user_id" gorm:"type:uuid;not null"`
	User        userModel.User `json:"user" gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE;"`
	AccessToken string         `json:"access_token" gorm:"type:text;not null"`
	ExpiredAt   time.Time      `json:"expired_at" gorm:"not null"`
	CreatedAt   time.Time      `json:"-" gorm:"not null;default:now()"`
	UpdatedAt   time.Time      `json:"-" gorm:"not null;default:now()"`
}

type RefreshToken struct {
	ID            uuid.UUID   `json:"id" gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	AccessTokenID uuid.UUID   `json:"access_token_id" gorm:"type:uuid;not null"`
	AccessToken   AccessToken `json:"access_token" gorm:"foreignKey:AccessTokenID;constraint:OnDelete:CASCADE;"`
	RefreshToken  string      `json:"refresh_token" gorm:"type:text;not null"`
	ExpiredAt     time.Time   `json:"expired_at" gorm:"not null"`
	CreatedAt     time.Time   `json:"-" gorm:"not null;default:now()"`
	UpdatedAt     time.Time   `json:"-" gorm:"not null;default:now()"`
}

type LoginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type ResponseToken struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
}

type Payload struct {
	Payload string `json:"payload"`
}
