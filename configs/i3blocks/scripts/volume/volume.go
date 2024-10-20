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
	names,err :=  exec.Command("bash", "-c", "pactl list sinks | grep Description | cut -d ':' -f 2 | cut -c2-").Output()
	sinks,err :=  exec.Command("bash", "-c", "pactl list short sinks").Output()
	sinks_inputs,err :=  exec.Command("bash", "-c", "pactl list short sink-inputs").Output()

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
		case "2":
			var next_sink int
			if running_device == len(strings.Split(string(sinks), "\n")) - 2 {
				next_sink = 0
			} else {
				next_sink = running_device + 1
			}
			sink_id := strings.Fields(strings.Split(string(sinks), "\n")[next_sink])[0]
			exec.Command("bash", "-c", "pactl set-default-sink "+sink_id).Run()

			for _,sink := range strings.Split(string(sinks_inputs), "\n") {
				if sink != "" {
					sinkInput_id := strings.Fields(sink)[0]
					exec.Command("bash", "-c", "pactl move-sink-input "+sinkInput_id+" "+sink_id).Run()
				}
			}
			running_device = next_sink
		}

	}
	

	Volumes,err := exec.Command("bash", "-c", "pactl list sinks | grep 'Volume: front' | cut -d '/' -f 2 | tr -d ' '").Output()
	if err != nil {
		fmt.Println("pactl failed")
	}

	Volume := strings.Split(string(Volumes), "\n")[running_device]
	names_split := strings.Split(string(names), "\n")

	fmt.Println(names_split[running_device], Volume)
}
