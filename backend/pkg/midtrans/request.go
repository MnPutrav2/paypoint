package midtrans

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"errors"
	"io"
	midtransModel "kavi-kasir/internal/model/midtrans"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"

	"github.com/joho/godotenv"
)

func Transaction(item []midtransModel.ItemDetails, total int, name, phone, email, orderId string) (midtransModel.Response, error) {
	_ = godotenv.Load()
	url := os.Getenv("MIDTRANS_URL") + "/snap/v1/transactions"

	key := base64.StdEncoding.EncodeToString([]byte(os.Getenv("SERVER_KEY") + ":"))

	body, err := json.Marshal(midtransModel.PaymentRequest{
		PaymentType: "gopay",
		TransactionDetails: midtransModel.TransactionDetails{
			GrossAmount: total,
			OrderID:     orderId,
		},
		CustomerDetails: midtransModel.CustomerDetails{
			FirstName: name,
			LastName:  " ",
			Email:     email,
			Phone:     phone,
		},
		ItemDetails: item,
	})
	if err != nil {
		return midtransModel.Response{}, err
	}

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(body))
	if err != nil {
		return midtransModel.Response{}, err
	}

	req.Header.Set("Accept", "application/json")
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Basic "+key)

	client := &http.Client{
		Timeout: 10 * time.Second,
	}

	resp, err := client.Do(req)
	if err != nil {
		return midtransModel.Response{}, err
	}
	defer resp.Body.Close()

	b, err := io.ReadAll(resp.Body)
	if err != nil {
		return midtransModel.Response{}, err
	}

	if resp.Status != "201 Created" {
		var x midtransModel.Error
		if err := json.Unmarshal(b, &x); err != nil {
			return midtransModel.Response{}, err
		}

		return midtransModel.Response{}, errors.New(strings.Join(x.ErrorMes, ", "))
	}

	var e midtransModel.Response
	if err := json.Unmarshal(b, &e); err != nil {
		return midtransModel.Response{}, err
	}

	return e, nil
}

func Status(inv string) (midtransModel.ResponseStatus, error) {
	encoded := url.PathEscape(inv)
	// fmt.Println(encoded)
	_ = godotenv.Load()
	url := os.Getenv("MIDTRANS_API") + "/v2/" + encoded + "/status"

	res, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return midtransModel.ResponseStatus{}, err
	}

	key := base64.StdEncoding.EncodeToString([]byte(os.Getenv("SERVER_KEY") + ":"))
	res.Header.Set("Authorization", "Basic "+key)
	res.Header.Set("Accept", "application/json")

	client := &http.Client{}
	resp, err := client.Do(res)
	if err != nil {
		return midtransModel.ResponseStatus{}, err
	}
	defer resp.Body.Close()

	var result midtransModel.MidtransStatusResponse
	err = json.NewDecoder(resp.Body).Decode(&result)
	if err != nil {
		return midtransModel.ResponseStatus{}, err
	}

	return midtransModel.ResponseStatus{Status: result.TransactionStatus}, nil
}
