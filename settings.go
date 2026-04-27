package main

import (
	"encoding/json"
	"fmt"
	"math"
	"os/exec"
	"time"
)

const (
	VURate = 28
)

func initAudioEngine() {
	fmt.Println("Audio Analysis Engine start...")
	go StartVUMeters()
}

func StartVUMeters() {
	// Namen moeten exact matchen met Pactl.gd
	go monitorFast("mixer-in-1", "Mix_CH1")
	go monitorFast("mixer-master-A", "Master_A")
	go monitorAnalog("mixer-master-A", "Master_A")
}

func monitorFast(sinkName string, godotID string) {
	cmd := exec.Command("parec", "--device="+sinkName+".monitor", "--format=s16le", "--channels=2", "--rate=22050", "--latency-msec=100")
	stdout, _ := cmd.StdoutPipe()
	cmd.Start()
	
	buffer := make([]byte, 4096)
	ticker := time.NewTicker(time.Duration(1000/VURate) * time.Millisecond)
	var maxL, maxR float64
	gain := 1.1
	if godotID == "Master_A" { gain = 1.5 }

	for {
		select {
		case <-ticker.C:
			mono := (maxL + maxR) / 2
			if mono > 1.0 { mono = 1.0 }
			if globalConn != nil && addrGodot != nil {
				msg := fmt.Sprintf("VU|%s|%.4f", godotID, mono)
				globalConn.WriteToUDP([]byte(msg), addrGodot)
			}
			maxL, maxR = 0, 0
		default:
			n, err := stdout.Read(buffer)
			if err != nil { return }
			for i := 0; i < n; i += 4 {
				if i+3 >= n { break }
				l := math.Abs(float64(int16(uint16(buffer[i])|uint16(buffer[i+1])<<8))) / 32768.0 * gain
				r := math.Abs(float64(int16(uint16(buffer[i+2])|uint16(buffer[i+3])<<8))) / 32768.0 * gain
				if l > maxL { maxL = l }; if r > maxR { maxR = r }
			}
		}
	}
}

func monitorAnalog(sinkName string, godotID string) {
	cmd := exec.Command("parec", "--device="+sinkName+".monitor", "--format=s16le", "--channels=2", "--rate=22050", "--latency-msec=100")
	stdout, _ := cmd.StdoutPipe()
	cmd.Start()
	
	buffer := make([]byte, 2048)
	ticker := time.NewTicker(time.Duration(1000/VURate) * time.Millisecond)
	var maxL, maxR float64
	gain := 1.0

	for {
		select {
		case <-ticker.C:
			if globalConn != nil && addrGodot != nil {
                msg := fmt.Sprintf("AVU|%s|%.4f|%.4f", godotID, maxL, maxR)
                globalConn.WriteToUDP([]byte(msg), addrGodot)
			}
			maxL, maxR = 0, 0
		default:
			n, err := stdout.Read(buffer)
			if err != nil { return }
			for i := 0; i < n; i += 4 {
				if i+3 >= n { break }
				l := math.Abs(float64(int16(uint16(buffer[i])|uint16(buffer[i+1])<<8))) / 32768.0 * gain
				r := math.Abs(float64(int16(uint16(buffer[i+2])|uint16(buffer[i+3])<<8))) / 32768.0 * gain
				if l > maxL { maxL = l }; if r > maxR { maxR = r }
			}
			if maxL > 1.0 { maxL = 1.0 }; if maxR > 1.0 { maxR = 1.0 }
		}
	}
}

// DE ENIGE HANDSHAKE FUNCTIE IN HET HELE PROJECT
func sendHandshake(id string, msg string) {
	if globalConn != nil && addrGodot != nil {
		resp := map[string]string{
			"id":     id,
			"msg":    msg,
			"status": "OK",
		}
		data, _ := json.Marshal(resp)
		globalConn.WriteToUDP(data, addrGodot)
	}
}