package password

import (
	"os"

	"github.com/joho/godotenv"
	"golang.org/x/crypto/bcrypt"
)

func HashPassword(password string) (string, error) {
	_ = godotenv.Load()
	pepper := os.Getenv("PEPPER")

	passwordWithPepper := password + pepper

	hash, err := bcrypt.GenerateFromPassword([]byte(passwordWithPepper), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}

	return string(hash), nil
}
