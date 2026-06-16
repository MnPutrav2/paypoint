package cmd

import (
	"bufio"
	"fmt"
	"kavi-kasir/internal/config"
	"log"
	"os"
	"strings"
)

func Rollback() {
	fmt.Println("⚠️  WARNING: This will DROP ALL TABLES in the database.")
	fmt.Print("Mau lanjutkan? (y/N): ")

	reader := bufio.NewReader(os.Stdin)
	input, err := reader.ReadString('\n')
	if err != nil {
		fmt.Println("Failed to read input:", err)
		return
	}

	input = strings.TrimSpace(strings.ToLower(input))

	if input != "y" && input != "yes" {
		fmt.Println("❌ Rollback cancelled.")
		return
	}
	fmt.Println("Running rollback ... ==================")
	db, err := config.InitDB()
	if err != nil {
		log.Println("Database connection error:", err)
		return
	}
	migrator := db.Migrator()

	tables, err := migrator.GetTables()
	if err != nil {
		return
	}

	for _, table := range tables {
		if err := migrator.DropTable(table); err != nil {
			log.Printf("Failed to drop table %s: %v\n", table, err)
			return
		}
		fmt.Println("✅ Rolled back: ", table)
	}

	fmt.Println("Rollback completed successfully ==================")

}
