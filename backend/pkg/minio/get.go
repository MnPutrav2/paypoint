package minio

import (
	"context"
	"net/url"
	"os"
	"strings"
	"time"

	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
)

func GetFile(client *minio.Client, bucket, object string) (*minio.Object, error) {
	return client.GetObject(context.Background(), bucket, object, minio.GetObjectOptions{})
}

// Helper untuk generate public URL setelah upload
func GetPublicURL(objectName string) string {
	if strings.HasPrefix(objectName, "http") {
		return objectName
	}

	minioClient, err := minio.New("localhost:9000", &minio.Options{
		Creds:  credentials.NewStaticV4("minioadmin", "minioadmin", ""),
		Secure: false,
	})
	if err != nil {
		panic(err)
	}

	// publicURL := os.Getenv("MINIO_PUBLIC_URL")
	bucketName := os.Getenv("MINIO_BUCKET")

	presignedURL, err := minioClient.PresignedGetObject(
		context.Background(),
		bucketName,
		objectName,
		time.Minute*30,
		url.Values{},
	)
	if err != nil {
		panic(err)
	}

	return presignedURL.String()
}
