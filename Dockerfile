ARG nodeVersion=16
ARG nodeImage=node:${nodeVersion}-bullseye

# Stage 1
FROM ${nodeImage} as builder

ENV NEXT_TELEMETRY_DISABLED=1

WORKDIR /app/

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --no-progress

COPY next.config.js .eslintrc.json next-env.d.ts postcss.config.js tailwind.config.js tsconfig.json ./
COPY components ./components
COPY pages ./pages
COPY public ./public
COPY styles ./styles
COPY utils ./utils

RUN yarn build

# Stage 2

FROM $nodeImage as production

WORKDIR /app/
COPY --from=builder /app/package.json /app/yarn.lock ./
RUN yarn install --frozen-lockfile --no-progress --production=true

# Stage 3

FROM $nodeImage as runner

ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV production

RUN apk add zsh wget

RUN addgroup --gid 1001 nodejs
RUN mkdir /home/nodejs
RUN adduser nextjs --uid 1001 --gid 1001 --shell /bin/zsh --home /home/nodejs

WORKDIR /app/

RUN chown -R nextjs:nodejs /app

COPY --from=production /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./
COPY --from=builder /app/components ./components
COPY --from=builder /app/pages ./pages
COPY --from=builder /app/styles ./styles
COPY --from=builder /app/utils ./utils

WORKDIR /home/nodejs

RUN chown -R nextjs:nodejs /home/nodejs

USER nextjs

RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
RUN echo "ZSH_THEME=cloud" >> /home/nodejs/.zshrc

EXPOSE 3000
ENV NEXT_TELEMETRY_DISABLED 1