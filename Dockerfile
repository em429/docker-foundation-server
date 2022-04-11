FROM node:12-slim@sha256:19abd82b7f0c435b9e233995003ca251a3df8074470973c76011ab3034ee14fa

# Install build dependencies:
RUN apt-get update -yy \
    && apt-get install -yy --no-install-recommends \
       ca-certificates=20200601~deb9u2 \
       git=1:2.11.0-3+deb9u7 \
       build-essential=12.3 \
       python3=3.5.3-1 libsodium-dev=1.0.11-2 \
       libboost-system-dev=1.62.0.1 \
    && rm -rf /var/lib/apt/lists/*

# Clone a specific, know working version of foundation:
RUN git clone https://github.com/blinkhash/foundation-server.git /foundation-server
WORKDIR /foundation-server
RUN git checkout 7ed170e6668fb3970d3a0a094200d697deef7669 && rm -r .git

RUN chown -R node:node ./
USER node
ENV NODE_ENV production

# Build dependecies and install necessary node modules:
RUN npm clean-install \
    && npm uninstall nodemon pm2 \
    && npm cache clean --force \
    && rm -r /home/node/.npm

# Remove unecessary buildtime dependencies to reduce image size:
# TODO: check if libsodium or libboost is needed during runtime or can be safely removed after build?
# RUN apt-get remove git build-essential python3 libsodium-dev libboost-system-dev -yy && apt-get autoremove -yy
USER root
RUN apt-get remove git build-essential -yy && apt-get autoremove -yy

# Switch back to node user and run foundation:
USER node
WORKDIR /foundation-server
CMD [ "node", "scripts/main.js" ]
