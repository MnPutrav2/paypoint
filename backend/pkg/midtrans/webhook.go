package midtrans

import (
	midtransModel "kavi-kasir/internal/model/midtrans"
	"kavi-kasir/pkg/util"
	"net/http"
)

func Webhook(r *http.Request) (midtransModel.MidtransWebhook, error) {
	body, err := util.BodyDecoder[midtransModel.MidtransWebhook](r)
	if err != nil {
		return midtransModel.MidtransWebhook{}, err
	}

	return body, err
}
