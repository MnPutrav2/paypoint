package page

import "kavi-kasir/internal/model"

func SummarizedResponse(body any) model.SummarizedResponse {
	return model.SummarizedResponse{
		Result: body,
		Meta:   model.MetaRefOnly{},
	}
}
