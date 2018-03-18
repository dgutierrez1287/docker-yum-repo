Docker-Yum-Repo
============================

docker-yum-repo builds a yum repo server to run in a docker container. It is built
off of CentOS 7 and will update the repo automatically when an rpm is added or removed
courtesy of a custom repo scanner written in go using [rjeczalik/notify](https://github.com/rjeczalik/notify)


## Install

```
docker pull dgutierrez1287/yum-repo
``` 

## Use 

The bare minimum need to run the container is a link to the repo directory on the host
and port.

```
docker run -d -p 8080:80 -v /opt/repo:/repo dgutierrez1287/yum-repo
```

### Mapping Logs

There is a log volume (/logs) that can be mapped to the host machine. In that directory 
nginx, supervisord and the custom go program (repoScanner) will log to subdirectories.

### Environment Variables 

There are three environment variables that can be set to change the operation of the repoScanner and the entrypoint script to configure the container at runtime

DEBUG (String, Default: 'true') - This will enable debug logging for the repo scanner program, this should only be run for debugging since the log is very chatty.

LINUX_HOST (String, Default: 'true') - This container should be run on a linux host for production in which case this should be true, if you wanted to test this on docker for Windows or docker for Mac set this to false. I have found that Docker on a non linux platform will only send the file system notifications available for that system which is a subset of what is available for Linux. This setting will change the repo scanner to only look for the notifications available from Windows and Mac (if its false) or the notifications only available from Linux machines (if its true).

    Note: When running in non linux host mode the create repo tasks will fire more then once even if there is only one file placed in a repo directory, this is because the notifications available for non linux hosts are not a precise as the ones for Linux hosts. please see https://godoc.org/github.com/rjeczalik/notify for more detail.

SERVE_FILES (String, Default 'true') - This will stop nginx on the container from starting, this should be used if you only want to use the repo scanner portion of the container and will serve the files some other way. This could be accomplished by not mapping the port but this will set nginx to not run thereby saving a few extra resources.

### Using the Repo Directory

The repo_scanner script will watch any subdirectory in the /repo directory and will run
the yum repo create on any directory containing RPM files. This means that you can host
one or a hundred repos on the same container, and there is no directory structure
enforced or needed by the update script. The script will respond to any close file,
move file or delete file action of an RPM in the subdirectories in the /repo directory.

## User Feedback

### Issues
This image is created and maintained as a best effort. Please feel free to contact me and 
let me know any issues that come up with the image or make an issue on the 
[Github page](https://github.com/dgutierrez1287/docker-yum-repo)

### Contributing 
You are invited to contribute any new features or fixes; and I am happy to receive pull 
requests.

## Disclaimer

This module is provided without warranty of any kind, the creator(s) and contributors do their best to ensure stablity but can make no warranty about the stability of this docker image in different environments. The creator(s) and contributors reccomend that you test this image and all future releases of this image in your environment before use.

## ChangeLog

Version: 1.0.0, 2017-03-22

This initial release happened months ago however since I am going to be making some heavy changes I figured I would tag it to maintain the point in time.

Version: 2.0.0, 2018-03-18

This is almost a full re-write with many new features. The ruby script has been replaced by a go program, which will do an inital scan at start up and uses concurrency and file locking. I have added multi-stage build process for the container to bring down the final container size. I have also added controls for not enabling nginx (if file serving will be done another way and to save resouces) amd turning on debugging.
