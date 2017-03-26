Docker-Yum-Repo
============================

docker-yum-repo builds a yum repo server to run in a docker container. It is built
off of CentOS 7 and will update the repo automatically when an rpm is added or removed
courtesy of a custom ruby script using [rb-inotify](https://github.com/nex3/rb-inotify)


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
nginx, supervisord and the custom rudy script (repo_scanner) will log to subdirectories.

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