package mapper

import (
	"kavi-kasir/internal/model"
	bankModel "kavi-kasir/internal/model/bank"
)

func MappingBank(req bankModel.Bank) bankModel.BankShow {
	return bankModel.BankShow{
		ID:       req.ID,
		KodeBank: req.KodeBank,
		Nama:     req.Nama,
	}
}

func MappingBankAll(req []bankModel.Bank) []bankModel.BankShow {
	ma := make([]bankModel.BankShow, 0, len(req))

	for _, item := range req {
		ma = append(ma, bankModel.BankShow{
			ID:       item.ID,
			KodeBank: item.KodeBank,
			Nama:     item.Nama,
		})
	}

	return ma
}

func MappingBankUpdate(req bankModel.BankUpdate) []model.UpdateKey {
	return []model.UpdateKey{
		{
			Key:   "nama",
			Value: req.Nama,
		},
		{
			Key:   "kode_bank",
			Value: req.KodeBank,
		},
	}
}
