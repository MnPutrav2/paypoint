package minio

import (
	"context"
	"log"

	"github.com/minio/minio-go/v7"
)

func EnsureBucket(client *minio.Client, bucket string) {
	ctx := context.Background()

	exists, err := client.BucketExists(ctx, bucket)
	if err != nil {
		log.Fatal(err)
	}

	if !exists {
		err = client.MakeBucket(ctx, bucket, minio.MakeBucketOptions{})
		if err != nil {
			log.Fatal(err)
		}
	}
}
