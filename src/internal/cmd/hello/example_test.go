//go:build !without_examples

package cmd

import (
	"fmt"
)

func ExampleGoodDay() {
	fmt.Println("Hello by Example")
	// Output: Hello by Example
}

func ExampleMain() {
	fmt.Println("Its Main")
}

func ExampleMain_extended() {
	fmt.Println("Its Main")
}
