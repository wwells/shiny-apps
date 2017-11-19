# Suite for managing shinyR application to display Data Commons resource use

Full respository at: https://github.com/occ-data/metering-shinyapp

# Deploy

## Option 1: Pull from Quay Repo

Get container from Quay.

```
docker pull quay.io/occ_data/costapp
```

Tmux/Screen to multiplex. Then run the container injecting your own local global.R creds in to the application.

```
sudo docker run --rm -v $(pwd)/global.R:/srv/shiny-server/global.R -p 80:80 --name costapp quay.io/occ_data/costapp
```

## Option 2: Build your own container

Clone the repo, make any desired updates, then build.

```
docker build -t costapp .
```

Run your build: Insert your global.R keys to make it work.

```
docker run --rm -v $(pwd)/global.R:/srv/shiny-server/global.R -p 80:80 --name costapp costapp
```
