# A small Python Daemon which detects finished tasks via file creations

This daemon monitors file creations in the /wd directory (wd = working directory) which you need to provide via a volume mount.

The detected files must end with ".finished" as file extension and will be deleted after detection (but logged to stdout).

This will only happen once. If you get two "foo.finished" files created, the first creation will be deleted and the second will be ignored (because this task is already finished).

You inform the daemon of the files (which are named customers) to look out for via CLI parameters.

When everything was detected, it will exit with status code 0.

When it receives SIGKILL (e.g. from stopping the container), it will exit with status code 1.

# Example

```
podman run --rm \
    --volume /path/to/directory:/wd \
    finish-detection-daemon \
    foo \
    bar
```
