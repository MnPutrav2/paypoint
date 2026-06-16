package minio

import (
	"context"
	"fmt"
	"os"
	"strings"

	"github.com/minio/minio-go/v7"
)

func GetFile(client *minio.Client, bucket, object string) (*minio.Object, error) {
	return client.GetObject(context.Background(), bucket, object, minio.GetObjectOptions{})
}

// Helper untuk generate public URL setelah upload
func GetPublicURL(objectName string) string {
	if strings.HasPrefix(objectName, "http") {
		return objectName
	}

	publicURL := os.Getenv("MINIO_PUBLIC_URL")
	bucket := os.Getenv("MINIO_BUCKET")
	return fmt.Sprintf("%s/%s/%s", publicURL, bucket, objectName)
}
