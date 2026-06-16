package kategoriRepo

import (
	"context"
	"fmt"
	kategoriModel "kavi-kasir/internal/model/kategori"
)

func (q *kategoriRepository) Get(ctx context.Context, ref string, keyword string) (kategoriModel.Kategori, error) {
	var k kategoriModel.Kategori

	if err := q.db.WithContext(ctx).
		Model(&kategoriModel.Kategori{}).
		Joins("INNER JOIN ref_kategoris ON kategoris.ref_kategori_id = ref_kategoris.id").
		Where("ref_kategoris.nama = ?", ref).
		Where("kategoris.deskripsi = ?", keyword).
		Limit(100).
		Find(&k).Error; err != nil {
		fmt.Println("error in here")
		return kategoriModel.Kategori{}, err
	}

	fmt.Println(k)
	return k, nil
}
