package mapper

import (
	bankModel "kavi-kasir/internal/model/bank"
	rekeningModel "kavi-kasir/internal/model/rekening"
)

func MappingRekening(req rekeningModel.Rekening) rekeningModel.RekeningShow {
	return rekeningModel.RekeningShow{
		ID:            req.ID,
		Nama:          req.Nama,
		NomorRekening: req.NomorRekening,
		Bank: bankModel.BankShow{
			ID:       req.Bank.ID,
			KodeBank: req.Bank.KodeBank,
			Nama:     req.Bank.Nama,
		},
		Saldo: req.Saldo,
	}
}

func MappingRekeningAll(req []rekeningModel.Rekening) []rekeningModel.RekeningShow {
	ma := make([]rekeningModel.RekeningShow, 0, len(req))

	for _, item := range req {
		ma = append(ma, rekeningModel.RekeningShow{
			ID:            item.ID,
			Nama:          item.Nama,
			NomorRekening: item.NomorRekening,
			Bank: bankModel.BankShow{
				ID:       item.Bank.ID,
				KodeBank: item.Bank.KodeBank,
				Nama:     item.Bank.Nama,
			},
			Saldo: item.Saldo,
		})
	}

	return ma
}
