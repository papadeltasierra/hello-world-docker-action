# Container image that runs your code
FROM mcr.microsoft.com/windows/server:ltsc2022

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.cmd /entrypoint.cmd

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.cmd"]