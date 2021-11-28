# nextcloud-smbkill

A simple script to kill dead-end `smbclient` processes on servers running a combination of Nextcloud and SMB shares.

## Background

Nextcloud can also integrate with SMB shares. However, using this can *sometimes* lead to the system spawning `smbclient` processes that never come to an end. These will completely pin a single CPU thread and do nothing else. In really bad cases, this can lead to the system spawning many of these processes that completely eat up the system's CPU resources for no reason.

This seems to be a [known issue](https://github.com/nextcloud/server/issues/6865), but no solution I could find fixed the issue.

## How it works

The script gets all PIDs of processes using the `/usr/bin/smbclient` executable.
It then finds the total time each process has been alive for as well as the total CPU time each process has occupied. If these are roughly equal (within 5 seconds of each other) and a process has been running for more than a minute, it will be killed since it's doing nothing but pinning the CPU.

Compared to just killing all long-running processes, this approach has the advantage of still allowing for things like long downloads.

## Usage

This script needs to be run periodically. Depending on how often you think it should be run, you can adjust the following commands / instructions.
The script also needs superuser privileges to run because it needs to be able to kill processes.

The easiest way to get this script to run periodically is to schudule a cron job.
This can be done using:

```bash
sudo crontab -e
```

Once you're inside the editor of your choice, simply add a line like this to the file:

```text
*/15 * * * * <path to the script>
```

This will run the script every 15 minutes.

Another way of adding a cron job is to add a file to `/etc/cron.d/`, although you then need to specify the shell to execute this with as well as the `PATH` environment variable:

```text
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

*/15 * * * * root <path to the script>
```
