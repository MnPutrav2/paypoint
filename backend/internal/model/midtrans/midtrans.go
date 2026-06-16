package midtransModel

import (
	orderModel "kavi-kasir/internal/model/order"

	"github.com/google/uuid"
)

type PaymentRequest struct {
	PaymentType        string             `json:"payment_type"`
	TransactionDetails TransactionDetails `json:"transaction_details"`
	CustomerDetails    CustomerDetails    `json:"customer_details"`
	ItemDetails        []ItemDetails      `json:"item_details"`
}

type TransactionDetails struct {
	GrossAmount int    `json:"gross_amount"`
	OrderID     string `json:"order_id"`
}

type CustomerDetails struct {
	Email     string `json:"email"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	Phone     string `json:"phone"`
}

type ItemDetails struct {
	ID       string `json:"id"`
	Price    int64  `json:"price"`
	Quantity int    `json:"quantity"`
	Name     string `json:"name"`
}

type Request struct {
	OrderID string `json:"order_id"`
}

type MidtransResponse struct {
	Token       uuid.UUID `json:"snap_token"`
	RedirectURL string    `json:"redirect_url"`
}

type Response struct {
	Token       uuid.UUID         `json:"snap_token"`
	RedirectURL string            `json:"redirect_url"`
	Data        *orderModel.Order `json:"data"`
}

type Error struct {
	ErrorMes []string `json:"error_messages"`
}

type MidtransWebhook struct {
	TransactionStatus string `json:"transaction_status"`
	OrderID           string `json:"order_id"`
	GrossAmount       string `json:"gross_amount"`
	PaymentType       string `json:"payment_type"`
	FraudStatus       string `json:"fraud_status"`
	StatusCode        string `json:"status_code"`
}

type ResponseStatus struct {
	Status string `json:"status"`
}

type MidtransStatusResponse struct {
	StatusCode    string `json:"status_code"`
	StatusMessage string `json:"status_message"`

	TransactionID string `json:"transaction_id"`
	OrderID       string `json:"order_id"`
	MerchantID    string `json:"merchant_id"`

	GrossAmount string `json:"gross_amount"`
	Currency    string `json:"currency"`

	PaymentType     string `json:"payment_type"`
	TransactionTime string `json:"transaction_time"`
	SettlementTime  string `json:"settlement_time,omitempty"`

	TransactionStatus string `json:"transaction_status"`
	FraudStatus       string `json:"fraud_status,omitempty"`

	ApprovalCode string `json:"approval_code,omitempty"`
	SignatureKey string `json:"signature_key,omitempty"`

	// Bank Transfer
	VANumbers       []VANumber `json:"va_numbers,omitempty"`
	PermataVANumber string     `json:"permata_va_number,omitempty"`

	// E-Wallet (GoPay, ShopeePay, dll)
	Actions []Action `json:"actions,omitempty"`

	// QRIS
	Acquirer string `json:"acquirer,omitempty"`

	// Credit Card
	MaskedCard string `json:"masked_card,omitempty"`
	CardType   string `json:"card_type,omitempty"`
	Bank       string `json:"bank,omitempty"`

	// Convenience Store (Indomaret / Alfamart)
	PaymentCode string `json:"payment_code,omitempty"`
	Store       string `json:"store,omitempty"`
}

type VANumber struct {
	Bank     string `json:"bank"`
	VANumber string `json:"va_number"`
}

type Action struct {
	Name   string `json:"name"`
	Method string `json:"method"`
	URL    string `json:"url"`
}

type MidtransStatusResponseSettle struct {
	StatusCode        string `json:"status_code"`
	StatusMessage     string `json:"status_message"`
	TransactionID     string `json:"transaction_id"`
	OrderID           string `json:"order_id"`
	GrossAmount       string `json:"gross_amount"`
	PaymentType       string `json:"payment_type"`
	TransactionTime   string `json:"transaction_time"`
	TransactionStatus string `json:"transaction_status"`
	SettlementTime    string `json:"settlement_time"`
	FraudStatus       string `json:"fraud_status"`
}

type MidtransExpireResponse struct {
	StatusCode        string `json:"status_code"`
	StatusMessage     string `json:"status_message"`
	OrderID           string `json:"order_id"`
	TransactionStatus string `json:"transaction_status"`
}
