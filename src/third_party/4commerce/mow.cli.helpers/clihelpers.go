package clihelpers

import (
	"fmt"
	"github.com/jawher/mow.cli"
	"os"
)

// StringOptConf contains the value and a flag to identify if argument is SetByUser.
type StringOptConf struct {
	Value *string
	SetByUser bool
}

// IntOptConf contains the value and a flag to identify if argument is SetByUser.
type IntOptConf struct {
	Value *int
	SetByUser bool
}

// BoolOptConf contains the value and a flag to identify if argument is SetByUser.
type BoolOptConf struct {
	Value *bool
	SetByUser bool
}

// NewCliStringOpt easily constructs an new mow cli.StringOpt.
func NewCliStringOpt(name string, value string, desc string, setByUser *bool) cli.StringOpt {
	return cli.StringOpt{Name: name, Value: value, Desc: desc, SetByUser: setByUser}
}

// NewCliBoolOpt easily constructs an new mow cli.BoolOpt.
func NewCliBoolOpt(name string, value bool, desc string, setByUser *bool) cli.BoolOpt {
	return cli.BoolOpt{Name: name, Value: value, Desc: desc, SetByUser: setByUser}
}

// NewCliIntOpt easily constructs an new mow cli.IntOpt.
func NewCliIntOpt(name string, value int, desc string, setByUser *bool) cli.IntOpt {
	return cli.IntOpt{Name: name, Value: value, Desc: desc, SetByUser: setByUser}
}

// CliValidateIntValue allows to validate an integer option for range of min to max.
func CliValidateIntValue(value int, minValue int, maxValue int) bool {
	return (value >= minValue) && (value <= maxValue)
}

// CliIntValueRangeErr creates a formatted err object for range errors.
func CliIntValueRangeErr(name string, value int, minValue int, maxValue int) error {
	// Build standard message
	return fmt.Errorf("Wrong argument value for \"%s\" [Got: %d, Allowed: %d-%d]", name, value, minValue, maxValue)
}

// CliExitWithErr halts the app and exit with message and code.
func CliExitWithErr(app *cli.Cli, cmd *cli.Cmd, errCode int, err error, printUsage bool) {
	// Print the error message
	fmt.Fprintf(os.Stderr, "\n\\_(o_o)_/\n    v\nError: %s\n", err.Error())
	// Show Usage
	if printUsage {
		cmd.PrintHelp()
	}
	// Leave and use After Handlers
	cli.Exit(errCode)
}
