package seeder

import "gorm.io/gorm"

type Seeder interface {
	Run(db *gorm.DB) error
	Name() string
	Model() interface{}
}
