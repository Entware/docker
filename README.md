# Building packages from Docker

A highly reproducible way to build Entware packages. A plesant way for Docker-addicted persons:)

## Usage

Create Docker image tagged as `builder`:
```
git clone https://github.com/Entware/docker.git
docker build docker --pull --tag builder
```

Create Docker volume for compilation:
```
docker volume create entware-home
```

Run Docker containter named as `builder`:
```
docker run --rm --mount source=entware-home,target=/home/me --interactive --tty --name builder builder
```

Follow [this manual](https://github.com/Entware/Entware/wiki/Compile-packages-from-sources#clone-the-entware-git-repository) for further steps, all dependencies are pre-installed in Docker image.

If you need second (3rd or more) terminal, type:
```
docker exec --interactive --tty builder bash
```

Extract compiled packages:
```
docker cp builder:/home/me/Entware/bin .
```

The `Start-Builder.ps1` (Start-Builder.sh) and `propagate_env.sh` scripts are very optional. It used by one of maintainers to dive into chosen arch-specific container from Windows (or Linux) and deploy some basic environment inside. It creates all necessary Docker volumes at first start, checks out Entware sources and prompts user for further compilation/development.
