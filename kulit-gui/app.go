package main

import (
	"bufio"
	"context"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"sync"
)

// App struct
type App struct {
	ctx           context.Context
	serverCmd     *exec.Cmd
	serverMutex   sync.Mutex
	serverLog     *os.File
}

// NewApp creates a new App application struct
func NewApp() *App {
	return &App{}
}

// startup is called when the app starts.
func (a *App) startup(ctx context.Context) {
	a.ctx = ctx
}

// shutdown is called when the app closes. We must kill the server.
func (a *App) shutdown(ctx context.Context) {
	a.StopServer()
}

// GetExecutableDir finds where the app is actually running from.
func (a *App) GetExecutableDir() (string, error) {
	exePath, err := os.Executable()
	if err != nil {
		return "", err
	}
	
	// If running via "wails dev", the executable is deep in temp folders.
	// We want the root of the project for development.
	if strings.Contains(exePath, "wails-dev") || strings.Contains(exePath, "go-build") {
		pwd, _ := os.Getwd()
		// Move up one level since we are in kulit-gui
		return filepath.Dir(pwd), nil
	}
	
	return filepath.Dir(exePath), nil
}

// GetModels scans the adjacent models/ directory for .gguf files
func (a *App) GetModels() ([]string, error) {
	baseDir, err := a.GetExecutableDir()
	if err != nil {
		return nil, err
	}

	modelsDir := filepath.Join(baseDir, "models")
	
	// Create models dir if it doesn't exist to prevent errors
	os.MkdirAll(modelsDir, 0755)

	entries, err := os.ReadDir(modelsDir)
	if err != nil {
		return nil, fmt.Errorf("failed to read models directory: %v", err)
	}

	var models []string
	for _, entry := range entries {
		if !entry.IsDir() && strings.HasSuffix(entry.Name(), ".gguf") {
			models = append(models, entry.Name())
		}
	}

	return models, nil
}

// StartServer launches the llamafile process
func (a *App) StartServer(modelName string, mode string) error {
	a.serverMutex.Lock()
	defer a.serverMutex.Unlock()

	// If already running, stop it first
	if a.serverCmd != nil && a.serverCmd.Process != nil {
		a.StopServer()
	}

	baseDir, err := a.GetExecutableDir()
	if err != nil {
		return err
	}

	modelPath := filepath.Join(baseDir, "models", modelName)
	if _, err := os.Stat(modelPath); os.IsNotExist(err) {
		return fmt.Errorf("model file not found: %s", modelPath)
	}

	// Determine binary name based on OS
	binName := "kulit.llamafile"
	if runtime.GOOS == "windows" {
		binName = "llamafile.exe"
	}
	
	binPath := filepath.Join(baseDir, "bin", binName)
	if _, err := os.Stat(binPath); os.IsNotExist(err) {
		return fmt.Errorf("engine not found at: %s", binPath)
	}

	// Ensure it's executable (Linux/Mac)
	if runtime.GOOS != "windows" {
		os.Chmod(binPath, 0755)
	}

	// Prepare arguments based on mode
	ctxSize := "4096"
	parallel := "1"
	if mode == "MAXIMUM" {
		ctxSize = "16384"
		parallel = "2"
	}

	args := []string{
		"--server",
		"-m", modelPath,
		"--host", "127.0.0.1",
		"--port", "3690",
		"--gpu", "disable",
		"--flash-attn", "off",
		"--no-warmup",
		"--numa", "distribute",
		"--threads", "0",
		"--ctx-size", ctxSize,
		"--parallel", parallel,
		"--cache-type-k", "f16",
	}

	if runtime.GOOS == "windows" {
		a.serverCmd = exec.Command(binPath, args...)
	} else {
		// On Linux/Mac, llamafiles are Ape (Actually Portable Executables).
		// Depending on kernel config, `exec.Command` might fail with "exec format error".
		// We execute it via bash/sh to invoke the shell wrapper header.
		bashArgs := []string{"-c", fmt.Sprintf(`"%s" %s`, binPath, strings.Join(args, " "))}
		a.serverCmd = exec.Command("sh", bashArgs...)
	}

	// Create log file
	logPath := filepath.Join(baseDir, "server.log")
	a.serverLog, err = os.OpenFile(logPath, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0666)
	if err != nil {
		return fmt.Errorf("failed to open log file: %v", err)
	}
	a.serverCmd.Stdout = a.serverLog
	a.serverCmd.Stderr = a.serverLog

	// Start the process
	if err := a.serverCmd.Start(); err != nil {
		return fmt.Errorf("failed to start engine: %v", err)
	}

	// Start a goroutine to wait for it to finish and clean up
	go func(cmd *exec.Cmd) {
		cmd.Wait()
		a.serverMutex.Lock()
		if a.serverCmd == cmd {
			a.serverCmd = nil
		}
		a.serverMutex.Unlock()
	}(a.serverCmd)

	return nil
}

// StopServer gracefully or forcefully kills the running llamafile
func (a *App) StopServer() error {
	a.serverMutex.Lock()
	defer a.serverMutex.Unlock()

	if a.serverCmd != nil && a.serverCmd.Process != nil {
		// Attempt graceful kill first (SIGTERM equivalents)
		if err := a.serverCmd.Process.Kill(); err != nil {
			fmt.Printf("Failed to kill process: %v\n", err)
		}
		
		a.serverCmd = nil
	}

	if a.serverLog != nil {
		a.serverLog.Close()
		a.serverLog = nil
	}

	// Just to be absolutely sure on Windows/Linux, we can issue a broad kill
	if runtime.GOOS == "windows" {
		exec.Command("taskkill", "/F", "/IM", "llamafile.exe").Run()
	} else {
		exec.Command("pkill", "-f", "llamafile").Run()
	}

	return nil
}

// CheckServerReady reads the log file to see if the server is listening
func (a *App) CheckServerReady() bool {
	baseDir, err := a.GetExecutableDir()
	if err != nil {
		return false
	}
	
	logPath := filepath.Join(baseDir, "server.log")
	file, err := os.Open(logPath)
	if err != nil {
		return false
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		if strings.Contains(line, "server is listening on") {
			return true
		}
		// Also check for common crash errors
		if strings.Contains(line, "assert(fabsf(fval) <= 4194303.f)") {
			return false // Hardware incompatible
		}
	}
	return false
}
