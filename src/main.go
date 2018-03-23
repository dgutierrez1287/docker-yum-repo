package main

import (
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
	"syscall"

	"github.com/Sirupsen/logrus"
	"github.com/rjeczalik/notify"
	"gopkg.in/dickeyxxx/golock.v1"
	"gopkg.in/natefinch/lumberjack.v2"
)

// Constants
const (
	// RepoDir the parent repo directory
	RepoDir = "/repo"
	// LogDir the parent log directory for the application
	LogDir = "/logs/repo-scanner"
	// LockFileName the name of the lockfile
	LockFileName = "repoUpdate.lock"
)

// Global Variables
var (
	// Var to hold the logger instance
	log = logrus.New()
	// Var to hold the compiled regex for finding an RPM
	rpmRegex, _ = regexp.Compile("^.*\\.rpm$")
)

// Types
type rpmPaths []string

// init()
// Init function to set up and configure logger
func init() {

	// Check debug env variable and set log level accordingly
	if strings.ToLower(os.Getenv("DEBUG")) == "true" {
		log.Level = logrus.DebugLevel
	} else {
		log.Level = logrus.InfoLevel
	}

	// Set log output to file and log rotation
	log.Out = &lumberjack.Logger{
		Filename:   LogDir + "/scanner.log",
		MaxSize:    500,
		MaxBackups: 3,
		MaxAge:     15,
	}
}

// checkErrorAndLog(err error)
// This will check if an error is not nil and will log out the error as fatal.
// This will take in the error as a parameter
// This will not return anything.
func checkErrorAndLog(e error) {
	if e != nil {
		log.Fatal(e.Error())
	}
}

// updateRepo(path string)
// This will run the update for the repo
// This will take in a pointer to the path
// This will return nothing
func updateRepo(path string) {

	lockfile := path + "/" + LockFileName
	log.Debugf("Trying to create lockfile %s", lockfile)
	golock.Lock(lockfile)

	cmd := "createrepo"
	cmdArgs := []string{"--update", path}

	log.Debugf("Running command: %s %s", cmd, strings.Join(cmdArgs, " "))

	if err := exec.Command(cmd, cmdArgs...).Run(); err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			status := exitErr.Sys().(syscall.WaitStatus)
			if status != 0 {
				log.Errorf("Could not update repo %s", path)
			}
		} else {
			checkErrorAndLog(err)
		}
	} else {
		log.Debugf("Successfully updated repo %s", path)
	}

	log.Debug("Unlocking directory")
	golock.Unlock(lockfile)
}

// findRpms(path string, info os.FileInfo, err error)
// This is used by filepath.walk on each file visited it will find directories that contain
// rpms and then add them to the list of rpmPaths
// This will take in rpmPaths as a reciever and parameters sent by filepath.walk
// This will return only an error if it can't go somewhere
func (paths *rpmPaths) findRpms(path string, info os.FileInfo, err error) error {
	if err != nil {
		checkErrorAndLog(err)
		return nil
	}
	// If the location is a directory check for RPMs
	if info.IsDir() {

		log.Debugf("Checking directory %s", path)

		// Get a list of files in the directory and loop
		files, _ := ioutil.ReadDir(path)
		for _, file := range files {
			log.Debugf("Checking file %s", file.Name())

			// If the file is an RPM add the directory to the list and break the loop
			if rpmRegex.MatchString(file.Name()) {
				log.Debugf("Adding %s to rpm directories", path)
				*paths = append(*paths, path)
				break
			}
		}
	}
	return nil
}

// initialScanAndUpdate()
// This will walk the repo directory and find all directories with rpms and run a repo update
// This will take in nothing
// This will return nothing
func initialScanAndUpdate() {

	log.Info("Running startup update of RPM directories")

	var paths rpmPaths

	// recursively walk the top repo directory to search for RPMs
	err := filepath.Walk(RepoDir, paths.findRpms)
	checkErrorAndLog(err)

	log.Infof("%d directories found that contain RPMs, running update", len(paths))

	for _, path := range paths {
		log.Debugf("Update %s", path)
		updateRepo(path)
	}
}

func main() {

	log.Info("Repo scanner starting ...")

	// Run the inital scan and update of all repos
	initialScanAndUpdate()

	// Make a buffered channel for file events
	log.Debug("Making event channel")
	ch := make(chan notify.EventInfo, 100)

	// Start a recursive watcher
	// Use different notify types based on docker host type
	// If the host is is linux then use the linux specific notify types
	if strings.ToLower(os.Getenv("LINUX_HOST")) == "true" {
		log.Debug("Linux Docker Host")
		err := notify.Watch(RepoDir+"/...", ch, notify.InCloseWrite, notify.InMovedTo, notify.InMovedFrom, notify.InDelete)
		checkErrorAndLog(err)

		// if the host is not linux then use the generic notify types
	} else {
		log.Debug("Non Linux Docker Host")
		err := notify.Watch(RepoDir+"/...", ch, notify.Write, notify.Create, notify.Remove, notify.Rename)
		checkErrorAndLog(err)
	}

	// Forever loop to process file events from the channel
	for {
		// Block until there is an event
		event := <-ch

		log.Debugf("Event %s on %s", event.Event().String(), event.Path())

		// if the event was an RPM file
		if rpmRegex.MatchString(event.Path()) {

			// Get the directory and start update
			rpmDir := filepath.Dir(event.Path())
			log.Infof("RPM change detected in %s", rpmDir)
			updateRepo(rpmDir)
		}
	}
}
