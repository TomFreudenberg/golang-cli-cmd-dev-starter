package mow_cli_helpers

import (
  "github.com/jawher/mow.cli"
  "fmt"
  "os"
)

func NewCliStringOpt(name string, value string, desc string, set_by_user *bool) cli.StringOpt {
  return cli.StringOpt{ Name: name, Value: value, Desc: desc, SetByUser: set_by_user }
}

func NewCliBoolOpt(name string, value bool, desc string, set_by_user *bool) cli.BoolOpt {
  return cli.BoolOpt{ Name: name, Value: value, Desc: desc, SetByUser: set_by_user }
}

func NewCliIntOpt(name string, value int, desc string, set_by_user *bool) cli.IntOpt {
  return cli.IntOpt{ Name: name, Value: value, Desc: desc, SetByUser: set_by_user }
}

func CliValidateIntValue(value int, min_value int, max_value int) bool {
  return (value >= min_value) && (value <= max_value)
}

func CliIntValueRangeError(name string, value int, min_value int, max_value int) string {
  // Build standard message
  return fmt.Sprintf("wrong argument value [%d] for [%s]. Values allowed from [%d-%d]!", value, name, min_value, max_value)
}

func CliExitWithError(app *cli.Cli, cmd *cli.Cmd, error_code int, error_message string, print_usage bool) {
  // Print the error message
  fmt.Fprintf(os.Stderr, "\n\\_(o_o)_/\n    v\nError: %s\n", error_message)
  // Show Usage
  if  (print_usage) {
    cmd.PrintHelp()
  }
  // Leave and use After Handlers
  cli.Exit(error_code)
}

