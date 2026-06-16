package model

import (
	katalogModel "kavi-kasir/internal/model/katalog"
	kategoriModel "kavi-kasir/internal/model/kategori"
	orderModel "kavi-kasir/internal/model/order"
	produkModel "kavi-kasir/internal/model/produk"
)

type ResponseMessage struct {
	Status    int             `json:"status"`
	Success   bool            `json:"success"`
	Message   string          `json:"message"`
	Reference ReferenceResult `json:"reference"`
}

type ResponseBody struct {
	Status    int             `json:"status"`
	Success   bool            `json:"success"`
	Result    any             `json:"result"`
	Reference ReferenceResult `json:"reference"`
}

type ResponseBodyPaginated struct {
	Status  int  `json:"status"`
	Success bool `json:"success"`
	Result  any  `json:"result"`
	Meta    any  `json:"meta"`
}

type PaginationResponse struct {
	Result any            `json:"result"`
	Meta   PaginationMeta `json:"meta"`
}
type SummarizedResponse struct {
	Result any         `json:"result"`
	Meta   MetaRefOnly `json:"meta"`
}

type PaginationMeta struct {
	TotalData int             `json:"total_data"`
	Page      int             `json:"page"`
	Size      int             `json:"size"`
	Previous  string          `json:"previous"`
	Next      string          `json:"next"`
	Reference ReferenceResult `json:"reference"`
}
type MetaRefOnly struct {
	Reference ReferenceResult `json:"reference"`
}

type ReferenceResult struct {
	Data *[]kategoriModel.Reference `json:"data"`
	Last *string                    `json:"last"`
}

type PaginationResponseTest struct {
	Result []produkModel.Produk `json:"result"`
	Meta   PaginationMeta       `json:"meta"`
}

type PaginationKategoriTest struct {
	Result []kategoriModel.KategoriShow `json:"result"`
	Meta   PaginationMeta               `json:"meta"`
}

type PaginationRefKategoriTest struct {
	Result []kategoriModel.RefKategoriShow `json:"result"`
	Meta   PaginationMeta                  `json:"meta"`
}

type OrderTest struct {
	Result []orderModel.Order `json:"result"`
	Meta   PaginationMeta     `json:"meta"`
}

type KatalogTest struct {
	Result []katalogModel.KatalogShow `json:"result"`
	Meta   PaginationMeta             `json:"meta"`
}

type UpdateKey struct {
	Key   string `json:"key"`
	Value any    `json:"value"`
}
