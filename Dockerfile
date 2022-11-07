FROM python:3.9-slim-bullseye
RUN apt-get update && apt-get install -y \
    curl gnupg apt-transport-https \
    unzip \
    csvkit \
    python3.9 python3-pip
RUN curl https://rclone.org/install.sh | bash

# === Install PowerShell ===

# Import the public repository GPG keys
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -

# Register the Microsoft Product feed
RUN sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-bullseye-prod bullseye main" > /etc/apt/sources.list.d/microsoft.list'

# Install PowerShell
RUN apt-get update \
    && apt-get install -y powershell \
    && rm -rf /var/lib/apt/lists/*

# === Done installing PowerShell ===

# Move to app directory and copy over app
ENV APPDIR /home/app
RUN mkdir ${APPDIR}
WORKDIR ${APPDIR}
COPY /app ${APPDIR}

# Set up python
ENV PATH=${PATH}:${APPDIR}/.local/bin
ENV PYTHONPATH=${PYTHONPATH}:${PWD}
RUN pip3 install poetry
RUN poetry config virtualenvs.create false
RUN poetry install --only main

ENTRYPOINT ["./docker-entrypoint.sh"]
