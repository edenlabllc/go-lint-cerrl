// Serves as a golangci-lint compatible plugin
// https://golangci-lint.run/contributing/new-linters/#configure-a-plugin
package main

import (
	"golang.org/x/tools/go/analysis"

	"github.com/edenlabllc/go-lint-cerrl/pkg/cerrl"
)

// AnalyzerPlugin is a required global variable for golangci-lint plugins
//nolint:deadcode
var AnalyzerPlugin analyzerPlugin

type analyzerPlugin struct{}

// GetAnalyzers returns a list of implemented analyzers.
// Implements an interface required for golangci-lint plugins.
func (*analyzerPlugin) GetAnalyzers() []*analysis.Analyzer {
	return []*analysis.Analyzer{
		cerrl.Analyzer(),
	}
}
