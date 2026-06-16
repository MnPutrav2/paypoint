package auth

import (
	"context"
	jwtEnc "kavi-kasir/pkg/auth/jwt"
	utilConst "kavi-kasir/pkg/util/const"
)

func GetUser(ctx context.Context) *jwtEnc.Claims {

	user := ctx.Value(utilConst.ContextUserID).(*jwtEnc.Claims)
	return user
}
