package main

import (
	"encoding/json"
	"fmt"
	"os"
)

func erro_exit(message string) {	
	fmt.Println(message)
	os.Exit(1)	
}

func main() {
	if len(os.Args) != 2 {
		erro_exit("Invalid number of arguments.")
	}

	data, err := os.ReadFile(os.Args[1])
	if err != nil {
    erro_exit("Could not open json file.")
  }

	var machine Machine
	if err := json.Unmarshal(data, &machine); err != nil {
		erro_exit("Could not open json file.")
  }

	fmt.Println("Machine name:", machine.Name)
	fmt.Println("States:", machine.States)
	fmt.Println("Initial:", machine.Initial)
	fmt.Println("Transitions from 'even':", machine.Transitions["even"])
}
