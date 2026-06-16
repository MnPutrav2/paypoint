package cmd

import (
	"fmt"
	"os"
	"time"
)

func job(name string) {
	fmt.Printf("[%s] job start: %s", time.Now().Format(time.RFC3339), name)
	// write code in here
}

func Schduler() {
	tm := len(os.Getenv("SCHEDULER_TIME"))
	ticker := time.NewTicker(time.Duration(tm) * time.Hour)
	defer ticker.Stop()

	go job("init")

	for t := range ticker.C {
		fmt.Println("tick at", t)
		go job("periodic")
	}
}
