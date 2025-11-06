// Serves as a golangci-lint compatible plugin
// https://golangci-lint.run/contributing/new-linters/#configure-a-plugin
package main

import (
	"github.com/edenlabllc/go-lint-cerrl/pkg/cerrl"
	"golang.org/x/tools/go/analysis"
)

//nolint:unparam
func New(_ any) ([]*analysis.Analyzer, error) {
	return []*analysis.Analyzer{
		cerrl.Analyzer(),
	}, nil
}
