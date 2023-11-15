FROM node:18.6.0-bullseye-slim AS build
RUN apt-get update && apt-get install -y --no-install-recommends dumb-init
WORKDIR /project
COPY package*.json /project/
RUN npm ci
COPY . /project/
RUN npm run build

FROM build AS clean
RUN npm prune --omit=dev \
    && rm -r src \
    && rm -f tsconfig.json \
    && rm -f tsconfig.tsbuildinfo

FROM node:18.6.0-bullseye-slim AS prod
COPY --chown=node:node --from=build /usr/bin/dumb-init /usr/bin/dumb-init
ENV NODE_ENV production
USER node
WORKDIR /project
COPY --chown=node:node --from=clean /project /project
CMD ["dumb-init", "node", "."]

# wait forever so you can inspect the container
# CMD ["tail", "-f", "/dev/null"] 