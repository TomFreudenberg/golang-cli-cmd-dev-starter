package hello

// Place your cmd global functions and types in here.

// hello is our internal function hello.
func helloGo() string {
	return "Hello Go from an internal pkg function!"
}

// GoodDay is our published function GoodDay.
func GoodDay() string {
	return "Good day from an internal pkg function!"
}
