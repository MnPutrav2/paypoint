package userService

import (
	errorhttp "kavi-kasir/internal/http/error"
	"kavi-kasir/internal/mapper"
	userModel "kavi-kasir/internal/model/user"
	jwtEnc "kavi-kasir/pkg/auth/jwt"
	"kavi-kasir/pkg/password"
)

func (s *userService) Login(user userModel.Login) (string, error) {
	res, err := s.repo.GetUserAccount(user)
	if err != nil {
		return "", err
	}

	if !password.CheckPassword(user.Password, res.Password) {
		return "", errorhttp.ErrUsernameOrPassword
	}

	token, exp, err := jwtEnc.GenerateJWT(res)
	if err != nil {
		return "", err
	}

	tokenReq := mapper.MappingTokenCreate(res.ID, token, exp)
	if err := s.repo.CreateAccessToken(&tokenReq); err != nil {
		return "", err
	}

	return token, nil
}
