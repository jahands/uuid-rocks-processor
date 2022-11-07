FROM mcr.microsoft.com/powershell:debian-bullseye-slim
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    csvkit \
    && rm -rf /var/lib/apt/lists/*
RUN curl https://rclone.org/install.sh | bash

# Setup user junk
RUN groupadd -g 999 worker && \
    useradd -r -u 999 -g worker worker
RUN mkdir /home/worker
RUN chown -R worker:worker /home/worker
USER worker

# App stuff
WORKDIR /home/worker
COPY /app ${HOME}
ENTRYPOINT ["./docker-entrypoint.sh"]
