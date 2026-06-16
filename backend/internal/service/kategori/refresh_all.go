package kategoriService

import (
	"context"
	kategoriModel "kavi-kasir/internal/model/kategori"
	"time"
)

func (s *kategoriService) RefreshReferenceDataService(ctx context.Context, tm *time.Time) ([]kategoriModel.Reference, string, error) {
	if tm == nil {
		last, err := emptyDate(s, ctx)
		return nil, last, err
	}

	data, last, err := s.repo.RefreshReferenceData(ctx, *tm)
	if err != nil {
		return nil, "", err
	}

	if last == "" {
		lastRef, err := emptyDate(s, ctx)
		return nil, lastRef, err
	}

	return data, last, nil
}

func emptyDate(s *kategoriService, ctx context.Context) (string, error) {
	lastRef, lastKat, err := s.repo.RefreshReferenceLast(ctx)
	if err != nil {
		return "", err
	}

	var last string
	if lastKat.After(lastRef) {
		last = lastKat.Format("2006-01-02 15:04:05")
	} else {
		last = lastRef.Format("2006-01-02 15:04:05")
	}

	return last, err
}
