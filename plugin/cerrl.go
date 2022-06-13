// Serves as a golangci-lint compatible plugin
// main package name is required by golangci-lint
package main

import (
	"golang.org/x/tools/go/analysis"

	"github.com/edenlabllc/go-lint-cerrl/pkg/cerrl"
)

// AnalyzerPlugin is a required global variable for golangci-lint plugins
//nolint:deadcode
var AnalyzerPlugin analyzerPlugin

type analyzerPlugin struct{}

// GetAnalyzers implements the interface required for golangci-lint plugins
func (*analyzerPlugin) GetAnalyzers() []*analysis.Analyzer {
	return []*analysis.Analyzer{
		cerrl.Analyzer(),
	}
}
