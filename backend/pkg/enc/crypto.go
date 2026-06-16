package enc

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"errors"
	"io"
	"os"
)

const (
	IVLength  = 12
	TagLength = 16
)

// deriveKey = sha256(secret)
func deriveKey(secret string) []byte {
	hash := sha256.Sum256([]byte(secret))
	return hash[:]
}

// EncryptPayload encrypt payload (struct/map) → base64 string
func EncryptPayload(payload any, secret string) (string, error) {
	key := deriveKey(secret)

	block, err := aes.NewCipher(key)
	if err != nil {
		return "", err
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return "", err
	}

	iv := make([]byte, IVLength)
	if _, err := io.ReadFull(rand.Reader, iv); err != nil {
		return "", err
	}

	plainJSON, err := json.Marshal(payload)
	if err != nil {
		return "", err
	}

	// Seal menghasilkan: ciphertext + tag
	ciphertext := gcm.Seal(nil, iv, plainJSON, nil)

	// Pisahkan tag (16 byte terakhir)
	tag := ciphertext[len(ciphertext)-TagLength:]
	encrypted := ciphertext[:len(ciphertext)-TagLength]

	// gabung: iv + tag + encrypted
	final := append(append(iv, tag...), encrypted...)

	return base64.StdEncoding.EncodeToString(final), nil
}

// DecryptPayload decrypt base64 → struct/map
func DecryptPayload(enc string, secret string) ([]byte, error) {
	data, err := base64.StdEncoding.DecodeString(enc)
	if err != nil {
		return []byte{}, err
	}

	if len(data) < IVLength+TagLength {
		return []byte{}, errors.New("invalid encrypted payload")
	}

	key := deriveKey(secret)

	iv := data[:IVLength]
	tag := data[IVLength : IVLength+TagLength]
	ciphertext := data[IVLength+TagLength:]

	block, err := aes.NewCipher(key)
	if err != nil {
		return []byte{}, err
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return []byte{}, err
	}

	// gabung kembali encrypted + tag
	fullCiphertext := append(ciphertext, tag...)

	plain, err := gcm.Open(nil, iv, fullCiphertext, nil)
	if err != nil {
		return []byte{}, err
	}

	return plain, nil
}

func DecryptResponse[T any](enc string) (T, error) {
	var e T
	ini := os.Getenv("INI_DIGINIIN")

	res, err := DecryptPayload(enc, ini)
	if err != nil {
		return e, err
	}

	var body T
	if err := json.Unmarshal(res, &body); err != nil {
		return e, err
	}

	return body, nil
}
