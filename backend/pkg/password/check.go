package password

import (
	"os"

	"github.com/joho/godotenv"
	"golang.org/x/crypto/bcrypt"
)

func CheckPassword(password, hash string) bool {
	_ = godotenv.Load()
	pepper := os.Getenv("PEPPER")

	passwordWithPepper := password + pepper
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(passwordWithPepper))
	return err == nil
}
