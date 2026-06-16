package middleware

import (
	"context"
	jwtEnc "kavi-kasir/pkg/auth/jwt"
	"kavi-kasir/pkg/response"
	util "kavi-kasir/pkg/util/const"
	"net/http"
	"os"
	"strings"

	"github.com/joho/godotenv"
)

var _ = godotenv.Load()
var jwtKey = []byte(os.Getenv("JWT_SECURE_KEY"))

func Authorization(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		auth := r.Header.Get("Authorization")
		split := strings.SplitN(auth, " ", 2)

		if split[0] != "Bearer" {
			response.Message("token need bearer", "token need bearer", "WARN", 401, w, r)
			return
		}

		claim, err := jwtEnc.ValidateJWT(split[1])
		// fmt.Println("Claim:", *claim)
		if err != nil {
			response.Message("unauthorization", err.Error(), "WARN", 401, w, r)
			return
		}
		// Inject userID ke context
		ctx := context.WithValue(r.Context(), util.ContextUserID, claim)

		// // Replace request context
		r = r.WithContext(ctx)

		next(w, r)
	}
}

// func Authorization(next http.HandlerFunc) http.HandlerFunc {
// 	return func(w http.ResponseWriter, r *http.Request) {

// 		auth := r.Header.Get("Authorization")
// 		split := strings.SplitN(auth, " ", 2)

// 		if len(split) != 2 || split[0] != "Bearer" {
// 			response.Message("token need bearer", "token need bearer", "WARN", 401, w, r)
// 			return
// 		}

// 		claim, err := jwtEnc.ValidateJWT(split[1])
// 		if err != nil {
// 			response.Message("unauthorization", err.Error(), "WARN", 401, w, r)
// 			return
// 		}

// 		// inject full claim ke context
// 		ctx := context.WithValue(r.Context(), "claim", claim)
// 		r = r.WithContext(ctx)

//			next(w, r)
//		}
//	}
func Token(r *http.Request) string {

	auth := r.Header.Get("Authorization")
	// Check Header
	split := strings.SplitN(auth, " ", 2)

	if len(split) != 2 || split[0] != "Bearer" {
		return ""
	}

	if split[0] != "Bearer" {
		return ""
	}

	return split[1]
}

func Authorization2(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		auth := r.Header.Get("Authorization")
		split := strings.SplitN(auth, " ", 2)

		if split[0] != "Bearer" {
			response.Message("token need bearer", "token need bearer", "WARN", 401, w, r)
			return
		}

		claim, err := jwtEnc.ValidateJWT(split[1])
		if err != nil {
			response.Message("unauthorization", err.Error(), "WARN", 401, w, r)
			return
		}

		ctx := context.WithValue(r.Context(), util.ContextUserID, claim)
		r = r.WithContext(ctx)

		next(w, r)
	}
}
