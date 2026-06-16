package authService

import (
	"context"
	"encoding/base64"
	errorhttp "kavi-kasir/internal/http/error"
	authModel "kavi-kasir/internal/model/auth"
	jwtEnc "kavi-kasir/pkg/auth/jwt"
	"kavi-kasir/pkg/password"
	"os"
	"strconv"
	"time"

	"github.com/google/uuid"
)

func (s *authService) AuthLoginService(ctx context.Context, payload authModel.LoginRequest) (authModel.ResponseToken, error) {
	user, err := s.repo.CheckUser(ctx, payload.Username)
	if err != nil {
		return authModel.ResponseToken{}, errorhttp.ErrAccountNotRegistered
	}

	if !password.CheckPassword(payload.Password, user.Password) {
		return authModel.ResponseToken{}, errorhttp.ErrUsernameOrPassword
	}

	token, exp, err := jwtEnc.GenerateJWT(user)
	if err != nil {
		return authModel.ResponseToken{}, err
	}

	tokenPayload := authModel.AccessToken{
		UserID:      user.ID,
		AccessToken: token,
		ExpiredAt:   exp,
	}

	refresh := base64.StdEncoding.EncodeToString([]byte(uuid.New().String()))
	refreshExp, _ := strconv.Atoi(os.Getenv("REFRESH_EXPIRED_HOUR"))
	refreshPayload := authModel.RefreshToken{
		RefreshToken: refresh,
		ExpiredAt:    time.Now().Add(time.Hour * time.Duration(refreshExp)),
	}
	if err := s.repo.SaveToken(ctx, &tokenPayload, &refreshPayload); err != nil {
		return authModel.ResponseToken{}, err
	}

	return authModel.ResponseToken{AccessToken: token, RefreshToken: refresh}, nil
}
