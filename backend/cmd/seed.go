package cmd

import (
	"fmt"
	"kavi-kasir/internal/config"
	"kavi-kasir/internal/database"
	"kavi-kasir/internal/database/seeder"
	authRepo "kavi-kasir/internal/repository/auth"
	authService "kavi-kasir/internal/service/auth"
	"log"
)

func Seed() {
	fmt.Println("Running GORM seed...")

	db, err := config.InitDB()
	if err != nil {
		log.Fatal(err)
	}

	if err := database.Migrate(db); err != nil {
		panic(err)
	}

	// * Urutan Seed
	// * 1. Bank
	// * 2. Reference
	// * 1. User
	// */

	seedersList := []seeder.Seeder{
		seeder.BankSeeder{},
		seeder.RefSeeder{},
		seeder.UserSeeder{
			Service: authService.NewAuthService(authRepo.NewAuthRepository(db)),
		},

		// isi seeder di sini
	}

	for _, s := range seedersList {
		fmt.Println("Seeding:", s.Name())
		if err := s.Run(db); err != nil {
			log.Fatalf("Seeder %s failed: %v", s.Name(), err)
		}
	}

	fmt.Println("Seeding completed")
}
