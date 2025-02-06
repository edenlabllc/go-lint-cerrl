// Package cerrl implements a go analyzer that catches not logged cerrors
package cerrl

import (
	"fmt"
	"go/ast"
	"regexp"

	"strings"

	"golang.org/x/tools/go/analysis"
	"golang.org/x/tools/go/analysis/passes/inspect"

	"golang.org/x/tools/go/ast/inspector"
)

var _cerrorPkgPatternSuffixPaths = []string{
	`/pkg/cerror(\"|$)`,
	`/pkg/cerror/v([0-9]+)(\"|$)`,
}

func Analyzer() *analysis.Analyzer {
	return &analysis.Analyzer{
		Name:     "cerrl",
		Doc:      "Checks that 'cerror.New***' calls are followed by a 'Log***' call",
		Run:      run,
		Requires: []*analysis.Analyzer{inspect.Analyzer},
	}
}

// run lints a single package. Is run once per package rather than separately per each file
func run(pass *analysis.Pass) (interface{}, error) {
	i, ok := pass.ResultOf[inspect.Analyzer].(*inspector.Inspector)
	if !ok {
		return nil, fmt.Errorf("pass.ResultOf doesn't contain inspect.Analyzer")
	}

	// inspected call expression nodes will be saved here
	visitedCallExprs := make(map[*ast.CallExpr]bool)

	nodeFilter := []ast.Node{
		(*ast.ImportSpec)(nil),
		(*ast.CallExpr)(nil),
	}

	var (
		cerrPkgName      string
		isImportFinished bool
	)

	// filtered ast nodes will be passed here recursively
	i.Preorder(nodeFilter, func(node ast.Node) {
		//nolint:nestif
		if is, ok := node.(*ast.ImportSpec); ok {
			// isImportFinished == true means that the previous file has completed its import block.
			// Need to reset the previous results
			if isImportFinished {
				isImportFinished = false
				cerrPkgName = ""
			}

			if is.Path != nil && hasSuffix(is.Path.Value, _cerrorPkgPatternSuffixPaths) {
				// is.Name == nil means the import has no alias
				if is.Name == nil {
					cerrPkgName = "cerror"
				} else {
					cerrPkgName = is.Name.Name
				}
			}

			return
		}

		// if we are here than the node is not an import statement.
		// so the import block is finished
		isImportFinished = true

		// no sense to move forward if cerror package was not imported
		if cerrPkgName == "" {
			return
		}

		ce, ok := node.(*ast.CallExpr)
		if !ok {
			return
		}

		// skip if the node was already inspcted during analyzing its parent nodes
		// for example if we have cerror.New().WithPayload().Log() call chain
		// the AST tree will look like
		// {
		//   Log {
		//     WithPayload {
		//       New
		//     }
		//   }
		// }
		// first of all we'll receive the Log Node and will analyze all nested
		// nodes recursively. So later when we'll receive the WithPayload and New
		// nodes again they won't be interesting for us
		if visitedCallExprs[ce] {
			return
		}

		// inspect that the call expression includes a cerror.New... call
		_, ok = isCallExprWithNewCall(ce, cerrPkgName, visitedCallExprs)
		if !ok {
			return
		}

		// inspect that the call expression ends with a .Log call
		_, ok = isLogCall(ce)
		if !ok {
			pass.Reportf(node.Pos(), "missing a .Log... call in chain after cerror.New...")
		}
	})

	return nil, nil
}

func hasSuffix(path string, list []string) bool {
	for _, pattern := range list {
		if ok, _ := regexp.MatchString(pattern, path); ok {
			return true
		}
	}

	return false
}

// isCallExprWithNewCall checks that a given call expression is a cerror.New* call
// or is a chain of calls where one of them is the cerror.New* call
// if the cerror.New call is found, its node will be returned from the func
// otherwise return nil, false
func isCallExprWithNewCall(ce *ast.CallExpr, cerrPkgName string, visitedCallExprs map[*ast.CallExpr]bool) (*ast.CallExpr, bool) {
	visitedCallExprs[ce] = true

	// check if the call expression is a direct cerror.New call
	if isNewCall(ce, cerrPkgName) {
		return ce, true
	}

	// check if the call expression has a nested call expression
	se, ok := ce.Fun.(*ast.SelectorExpr)
	if !ok {
		return nil, false
	}

	nestedCe, ok := se.X.(*ast.CallExpr)
	if !ok {
		return nil, false
	}

	// check if the nested call expression is a cerror.New call
	return isCallExprWithNewCall(nestedCe, cerrPkgName, visitedCallExprs)
}

// isLogCall checks if a given call expression is a direct Log call
func isLogCall(ce *ast.CallExpr) (*ast.SelectorExpr, bool) {
	se, ok := ce.Fun.(*ast.SelectorExpr)
	if !ok {
		return nil, false
	}

	if se.Sel == nil || !strings.HasPrefix(se.Sel.Name, "Log") {
		return nil, false
	}

	return se, ok
}

// isNewCall checks if a given call expression is a direct cerror.New call
func isNewCall(ce *ast.CallExpr, cerrPkgName string) bool {
	se, ok := ce.Fun.(*ast.SelectorExpr)
	if !ok {
		return false
	}

	x, ok := se.X.(*ast.Ident)
	if !ok {
		return false
	}

	if x.Name != cerrPkgName {
		return false
	}

	return strings.HasPrefix(se.Sel.Name, "New")
}
