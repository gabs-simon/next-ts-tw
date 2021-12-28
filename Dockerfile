ARG nodeVersion=16
ARG nodeImage=node:${nodeVersion}-alpine

# --------
# Stage 1
# --------
# Generates a build that will be used as a base for the final image

FROM ${nodeImage} as builder

WORKDIR /app/

# Installs dependencies, freezes the lockfile
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --no-progress

# Copies the application
COPY next.config.js .eslintrc.json next-env.d.ts postcss.config.js tailwind.config.js tsconfig.json ./
COPY components ./components
COPY pages ./pages
COPY public ./public
COPY styles ./styles
COPY utils ./utils

# Disables nextjs telemetry, builds the image

ENV NEXT_TELEMETRY_DISABLED=1
RUN yarn build

# --------
# Stage 2
# --------
# Copies the lockfiles from the builder image, generates an image with all locked and validated dependencies

FROM $nodeImage as dependencies

WORKDIR /app/
COPY --from=builder /app/package.json /app/yarn.lock ./
RUN yarn install --frozen-lockfile --no-progress

# --------
# Stage 3
# --------
# Pulls all dependencies, generates a user, installs oh-my-zsh, exposes the port and generates the image

FROM $nodeImage as runner

ENV NODE_ENV development

# Installs zsh and other dependencies
RUN apk add wget zsh git

# Generates the user nextjs:nodejs, sets its default shell to zsh
RUN addgroup -S nodejs
RUN mkdir /home/nextjs
RUN adduser nextjs --shell /bin/zsh --home /home/nextjs -G nodejs -D

WORKDIR /app/

# Pulls the application and dependencies from their corresponding images
COPY --from=dependencies /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./
COPY --from=builder /app/components ./components
COPY --from=builder /app/pages ./pages
COPY --from=builder /app/styles ./styles
COPY --from=builder /app/utils ./utils
COPY next.config.js .eslintrc.json next-env.d.ts postcss.config.js tailwind.config.js tsconfig.json .editorconfig ./

# @TODO: This is a workaround for a SWC related bug on nextjs
RUN npm i @next/swc-linux-x64-gnu -g

# Sets permissions
RUN chown -R nextjs:nodejs /app

WORKDIR /home/nextjs

# Gives permission to home directory
RUN chown -R nextjs:nodejs /home/nextjs

# As nextjs user, installs oh-my-zsh and exposes the 3000 port for development
USER nextjs

RUN echo "ZSH_THEME=cloud" >> /home/nextjs/.zshrc

EXPOSE 3000

# Don't forget to disable the nextjs telemetry
ENV NEXT_TELEMETRY_DISABLED 1