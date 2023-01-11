FROM node:18.12-bullseye-slim as base

ARG NODE_ENV=production
ENV NODE_ENV $NODE_ENV

ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=$PATH:/home/node/.npm-global/bin

RUN npm i -g npm@latest
RUN npm i -g @nestjs/cli

RUN mkdir /opt/node_app && chown node:node /opt/node_app
WORKDIR /opt/node_app
USER node

COPY --chown=node:node package.json package-lock.json* ./

FROM base as dev

RUN npm install
ENV PATH=$PATH:/opt/node_app/node_modules/.bin
COPY --chown=node:node . .
RUN npm run build

CMD ["npm", "run", "start:debug"]

FROM base as prod

RUN npm ci && npm cache clean --force
ENV PATH=$PATH:/opt/node_app/node_modules/
COPY --chown=node:node . .
RUN npm run build

CMD ["node", "dist/main"]