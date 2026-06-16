package algoritma

import (
	"fmt"
	"sort"
	"strings"
)

type Rule struct {
	Antecedent []string
	Consequent []string
	Support    float64
	Confidence float64
}

// join item jadi key unik
func join(items []string) string {
	tmp := make([]string, len(items))
	copy(tmp, items)
	sort.Strings(tmp)
	return strings.Join(tmp, ",")
}

// cek apakah item ada di slice
func contains(slice []string, item string) bool {
	for _, s := range slice {
		if s == item {
			return true
		}
	}
	return false
}

// cek subset
func isSubset(subset, set []string) bool {
	for _, s := range subset {
		if !contains(set, s) {
			return false
		}
	}
	return true
}

func generateCandidates(prev [][]string, k int) [][]string {
	var candidates [][]string
	m := map[string]bool{}

	for i := 0; i < len(prev); i++ {
		for j := i + 1; j < len(prev); j++ {

			a := prev[i]
			b := prev[j]

			// join jika prefix sama
			match := true
			for x := 0; x < k-2; x++ {
				if a[x] != b[x] {
					match = false
					break
				}
			}

			if !match {
				continue
			}

			candidate := append([]string{}, a...)
			candidate = append(candidate, b[len(b)-1])
			sort.Strings(candidate)

			key := join(candidate)
			if !m[key] {
				m[key] = true
				candidates = append(candidates, candidate)
			}
		}
	}

	return candidates
}

func countSupport(transactions [][]string, candidates [][]string) map[string]int {
	counts := make(map[string]int)

	for _, trx := range transactions {
		for _, cand := range candidates {
			if isSubset(cand, trx) {
				key := join(cand)
				counts[key]++
			}
		}
	}

	return counts
}

func Apriori(transactions [][]string, minSupport float64) map[string]float64 {
	total := float64(len(transactions))
	frequent := make(map[string]float64)

	// 1. L1 (1-itemset)
	itemCount := make(map[string]int)

	for _, trx := range transactions {
		for _, item := range trx {
			itemCount[item]++
		}
	}

	var L [][]string
	for item, c := range itemCount {
		support := float64(c) / total
		if support >= minSupport {
			L = append(L, []string{item})
			frequent[item] = support
		}
	}

	k := 2

	for len(L) > 0 {
		candidates := generateCandidates(L, k)
		if len(candidates) == 0 {
			break
		}

		counts := countSupport(transactions, candidates)

		var nextL [][]string
		for key, c := range counts {
			support := float64(c) / total
			if support >= minSupport {
				items := strings.Split(key, ",")
				nextL = append(nextL, items)
				frequent[key] = support
			}
		}

		L = nextL
		k++
	}

	return frequent
}

func combinations(items []string, length int) [][]string {
	var result [][]string

	var helper func(start int, comb []string)
	helper = func(start int, comb []string) {
		if len(comb) == length {
			tmp := make([]string, length)
			copy(tmp, comb)
			result = append(result, tmp)
			return
		}
		for i := start; i < len(items); i++ {
			helper(i+1, append(comb, items[i]))
		}
	}

	helper(0, []string{})
	return result
}

func generateRules(frequent map[string]float64, minConfidence float64) []Rule {
	var rules []Rule

	for key, supportAB := range frequent {
		items := strings.Split(key, ",")

		if len(items) < 2 {
			continue
		}

		for i := 1; i < len(items); i++ {
			subsets := combinations(items, i)

			for _, subset := range subsets {
				antecedent := subset

				var consequent []string
				for _, item := range items {
					if !contains(antecedent, item) {
						consequent = append(consequent, item)
					}
				}

				supportA, ok := frequent[join(antecedent)]
				if !ok {
					continue
				}

				conf := supportAB / supportA

				if conf >= minConfidence {
					rules = append(rules, Rule{
						Antecedent: antecedent,
						Consequent: consequent,
						Support:    supportAB,
						Confidence: conf,
					})
				}
			}
		}
	}

	return rules
}

func getRecommendations(rules []Rule, input []string) []Rule {
	var result []Rule

	for _, rule := range rules {
		if isSubset(rule.Antecedent, input) {
			result = append(result, rule)
		}
	}

	sort.Slice(result, func(i, j int) bool {
		return result[i].Confidence > result[j].Confidence
	})

	return result
}

func MarketBasket(transactions [][]string, input []string) []string {
	minSupport := 0.3
	minConfidence := 0.6

	frequent := Apriori(transactions, minSupport)
	rules := generateRules(frequent, minConfidence)
	recs := getRecommendations(rules, input)

	var result []string

	for _, r := range recs {
		result = append(result,
			fmt.Sprintf("%s + %s",
				strings.Join(r.Antecedent, ", "),
				strings.Join(r.Consequent, ", "),
			),
		)
	}

	return result
}
