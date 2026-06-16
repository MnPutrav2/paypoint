package invoice

import (
	"fmt"
	"time"
)

func Generate(next int) string {
	ut := fmt.Sprintf("%04d", next+1)
	tm := time.Now().Format("2006-01-02")
	inv := fmt.Sprintf("KAVI-INV-%s-%s", tm, ut)

	return inv
}
