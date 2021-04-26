// +build integration

package main

import (
	cmd "4commerce.net/golang/simple/internal/cmd/hello"
	"testing"
)

func TestConnectionStartStop(t *testing.T) {
	t.Log(cmd.GoodDay())
	t.Errorf("Stopped not looking for Good Day!")
}
