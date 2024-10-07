package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

func main() {
	var running_device int
	var is_there_are_running_device bool
	states,err := exec.Command("bash", "-c", "pactl list sinks | grep State").Output()
	for i,state := range strings.Split(string(states), "\n") {
		line := strings.Split(state, ":")
		s := strings.Trim(line[len(line) - 1], " ")
		if s == "RUNNING" {
			running_device = i
			is_there_are_running_device = true
			break
		}
	}

	if is_there_are_running_device == false {
		fmt.Println("No devices")
		return
	}

	block_button,bool := os.LookupEnv("BLOCK_BUTTON")
	if bool == true {
		switch block_button {
		case "4":
			exec.Command("bash", "-c", "pactl set-sink-volume @DEFAULT_SINK@ +5%").Run()
		case "5":
			exec.Command("bash", "-c", "pactl set-sink-volume @DEFAULT_SINK@ -5%").Run()
		}
	}
	

	Volumes,err := exec.Command("bash", "-c", "pactl list sinks | grep 'Volume: front' | cut -d '/' -f 2 | tr -d ' '").Output()
	if err != nil {
		fmt.Println("pactl failed")
	}

	Volume := strings.Split(string(Volumes), "\n")[running_device]
	fmt.Println(Volume)
}
