# FUP - Fast uploader
Upload your files quickly (through ssh).

## Installation
```sh
cd /opt
sudo git clone https://github.com/lifeisfoo/fup.git
sudo ln -s /opt/fup/fup.sh /usr/bin/fup
```
Now you can launch ```fup``` from everywhere.

## Usage
### 1. Create a .fup file
```sh
SSH_USR_HOST=user@host
REMOTE_DIR=public_html/plugins
```
### 2. Launch fup
```sh
fup
```

## Example
If you have a .fup file inside /home/lifeisfoo/dev/my-working-dir with:
```sh
SSH_USR_HOST=user@host
REMOTE_DIR=public_html/plugins
```
When ```fup``` is launched current directory will be archived (also the directory, not only files) and uploaded to ```user@host:public_html/plugins```. Remote ```public_html/plugins/my-working-dir``` will be created (if doesn't exists).

## Advanced configuration
These are default values that can be changed in the .fup file
```sh
SSH_PORT=21
TMP_DIR=/tmp
ARCHIVE_NAME=fup-to-upload.tar.bz2
#comma separated relative paths (no spaces)
#vcs directories and files are excluded by default. See tar man pages.
EXCLUDED_DIRS=dir1,dir2,dir3
#comma separated relative paths (no spaces)
#backup files are excluded by default. See tar man pages.
EXCLUDED_FILES=dir/file.js,another.file
```

## Requirements
A UNIX box and these tools (present in most GNU/Linux distributions and OSX yet):
* ssh
* scp
* tar
* bzip

## Pull request
Are welcome.

License
=======
GPL v3

## Author
Alessandro Miliucci <lifeisfoo@gmail.com>
