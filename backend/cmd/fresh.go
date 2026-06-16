package cmd

import (
	"fmt"
	"os"
	"os/exec"
)

func Fresh() {
	fmt.Println("Running rollback...")
	Rollback()

	// fmt.Println("Running migrate...")
	// if err := runCommand("go", "run", "./cmd/migrate"); err != nil {
	// 	log.Fatalf("Migration failed: %v", err)
	// }

	fmt.Println("Running seed...")
	Seed()

	fmt.Println("Migrate Fresh completed ===============")
}

func runCommand(name string, args ...string) error {
	cmd := exec.Command(name, args...)

	// supaya output muncul di terminal
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	return cmd.Run()
}
