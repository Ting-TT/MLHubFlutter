# MLFlutter Installers

Flutter supports multiple platform targets and the app will run native
on Android, iOS, Linux, MacOS, and Windows, as well as directly in a
browser from the web. While the Flutter functionality is in theory identical
across all platforms, mlflutter relies on mlhub packages being
available on the platform. At present we only support dekstops (Linux,
MacOS, and Windows).

## Prerequisite

Install R. See the instructions from the [R
Project](https://cloud.r-project.org/).

## Linux tar Archive

+ Download [mlflutter.tar.gz](https://access.togaware.com/mlflutter.tar.gz)

```bash
wget https://access.togaware.com/mlflutter.tar.gz
```

Then, to simply try it out locally:

```bash
tar zxvf mlflutter.tar.gz
mlflutter/mlfutter)
```

Or, to install for the current user:

```bash
tar zxvf mlflutter.tar.gz -C ${HOME}/.local/share/
ln -s ${HOME}/.local/share/mlflutter/mlflutter ${HOME}/.local/bin
```

For this user, to install a desktop icon and make it known to Gnome
and KDE:

```bash
wget https://raw.githubusercontent.com/gjwgit/mlflutter/dev/installers/mlflutter.desktop -O ${HOME}/.local/share/applications/mlflutter.desktop
mkdir -p ${HOME}/.local/share/icons/hicolor/scalable/apps/
wget https://raw.githubusercontent.com/gjwgit/mlflutter/dev/installers/mlflutter.svg -O ${HOME}/.local/share/icons/hicolor/scalable/apps/mlflutter.svg
```

Or, for a system-wide install:

```bash
sudo tar zxvf mlflutter.tar.gz -C /opt/
sudo ln -s /opt/mlflutter/mlflutter /usr/local/bin/
``` 

Once installed you can run the app as Alt-F2 and type `rattle` then
Enter.

## MacOS

The package file `mlflutter.dmg` can be installed on MacOS. Download
the file and open it on your Mac. Then, holding the Control key click
on the app icon to display a menu. Choose `Open`. Then accept the
warning to then run the app. The app should then run without the
warning next time.

## Windows Installer

Download and run the `mlflutter.exe` to self install the app on
Windows.
