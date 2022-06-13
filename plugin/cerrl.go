// Serves as a golangci-lint compatible plugin
// main package name is required by golangci-lint
package main

import (
	"golang.org/x/tools/go/analysis"

	"github.com/edenlabllc/go-lint-cerrl/pkg/cerrl"
	"github.com/edenlabllc/go-lint-cerrl/testdata/src/cerrl/pkg/cerror"
)

// AnalyzerPlugin is a required global variable for golangci-lint plugins
//nolint:deadcode
var AnalyzerPlugin analyzerPlugin

type analyzerPlugin struct{}

// GetAnalyzers implements the interface required for golangci-lint plugins
func (*analyzerPlugin) GetAnalyzers() []*analysis.Analyzer {
	cerror.New()

	return []*analysis.Analyzer{
		cerrl.Analyzer(),
	}
}
