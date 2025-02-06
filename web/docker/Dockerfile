# The value of "3.3.0" is just a placeholder. This is overwrote with the value written in .env.
ARG NODE_VER_ARG=20

# This image includes non-root user; "node"(uid: 1000, gid: 1000)
# Following version of npm and yarn have been installed in the base-image layer
# https://github.com/nodejs/docker-node/blob/b0de582b8d4627cc9d65a89bf3af1bfcf67d2bef/versions.json
FROM docker.io/library/node:${NODE_VER_ARG}-slim AS development
USER node
WORKDIR /home/node/web
CMD ["npm", "run", "dev"]

# Build stage
FROM development AS build
COPY --chown=node:node . .
RUN npm ci && npm run build

# preview stage
FROM nginx:latest AS preview
ARG PROD_WEB_PORT
EXPOSE $PROD_WEB_PORT
COPY --from=build /home/node/web/dist /var/www
COPY nginx/conf.d/prev.conf /etc/nginx/conf.d/default.conf

# Production stage
FROM nginx:latest AS production
ARG PROD_WEB_PORT
EXPOSE $PROD_WEB_PORT
COPY --from=build /home/node/web/dist /var/www
COPY nginx/conf.d/prod.conf /etc/nginx/conf.d/default.conf
