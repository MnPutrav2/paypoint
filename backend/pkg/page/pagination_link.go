package page

import (
	"fmt"
	"kavi-kasir/internal/model"
)

func PaginationLink(page, size, count int, keyword string) (string, string) {
	var previousLink string
	var nextLink string

	if page == 0 {
		previousLink = ""
	} else {
		previousLink = fmt.Sprintf("page=%d&size=%d", page-1, size)
	}

	if count <= (page+1)*size {
		nextLink = ""
	} else {
		nextLink = fmt.Sprintf("page=%d&size=%d", page+1, size)
	}

	if keyword != "" {
		if previousLink != "" {
			previousLink += fmt.Sprintf("&keyword=%s", keyword)
		}

		if nextLink != "" {
			nextLink += fmt.Sprintf("&keyword=%s", keyword)
		}
	}

	return previousLink, nextLink
}

func PaginationResponse(body any, page, size, total int, keyword string) model.PaginationResponse {
	previousLink, nextLink := PaginationLink(page, size, total, keyword)
	return model.PaginationResponse{
		Result: body,
		Meta: model.PaginationMeta{
			TotalData: total,
			Page:      page,
			Size:      size,
			Previous:  previousLink,
			Next:      nextLink,
		},
	}
}
