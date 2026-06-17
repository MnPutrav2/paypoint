package minio

import (
	"context"
	"fmt"
	"math/rand"
	"mime"
	"mime/multipart"
	"os"

	"github.com/minio/minio-go/v7"
)

func UploadFile(file multipart.File, size int64, contentType string, ext ...string) (string, error) {

	ctx := context.Background()
	client := NewMinio()
	bucket := os.Getenv("MINIO_BUCKET")
	publicURL := os.Getenv("MINIO_PUBLIC_URL")

	fileExt := ""
	if len(ext) > 0 && ext[0] != "" {
		fileExt = ext[0]
	} else {
		switch contentType {
		case "image/jpeg":
			fileExt = ".jpg"
		case "image/png":
			fileExt = ".png"
		case "image/webp":
			fileExt = ".webp"
		case "image/gif":
			fileExt = ".gif"
		case "application/pdf":
			fileExt = ".pdf"
		default:
			exts, err := mime.ExtensionsByType(contentType)
			if err == nil && len(exts) > 0 {
				fileExt = exts[0]
			}
		}
	}

	objectName := RandomStringFast(10) + fileExt

	_, err := client.PutObject(
		ctx,
		bucket,
		objectName,
		file,
		size,
		minio.PutObjectOptions{
			ContentType: contentType,
		},
	)
	if err != nil {
		return "", err
	}

	url := fmt.Sprintf("%s", objectName)

	fmt.Println("🔍 MINIO_PUBLIC_URL:", publicURL)
	fmt.Println("🔍 bucket:", bucket)
	fmt.Println("🔍 objectName:", objectName)
	fmt.Println("🔍 final url:", url)
	return url, nil
}

func RandomStringFast(length int) string {
	const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

	b := make([]byte, length)
	for i := range b {
		b[i] = chars[rand.Intn(len(chars))]
	}
	return string(b)
}
