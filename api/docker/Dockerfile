# The value of "3.3.0" is just a placeholder. This is overwrote with the value written in .env.
ARG RUBY_VER=3.3.0

# --- Common base stage for development and production ---
# Specify the base image by full name to make sure it from Docker Hub
FROM docker.io/library/ruby:${RUBY_VER}-slim AS base-common
ARG USER_ID \
    GROUP_ID \
    USER_NAME \
    GROUP_NAME \
    BUNDLE_BIN \
    BUNDLE_PATH
# Install common packages
RUN apt-get update -qq && \
    apt-get install \
      --no-install-recommends -y \
      curl \
      postgresql-client \
      libjemalloc2 \
      libvips
# Create non-root user and its home directory
RUN groupadd --gid $GROUP_ID $GROUP_NAME && \
    useradd $USER_NAME --uid $USER_ID --gid $GROUP_ID --create-home --shell /bin/bash
# Ensure BUNDLE_PATH exists and change its ownership;
# Create BUNDLE_BIN directory
RUN mkdir -p ${BUNDLE_PATH} ${BUNDLE_BIN} && \
    chown -R ${USER_ID}:${GROUP_ID} ${BUNDLE_PATH} ${BUNDLE_BIN}
# Set BUNDLE_*
ENV PATH="${BUNDLE_BIN}:${PATH}" \
    BUNDLE_PATH=${BUNDLE_PATH}

# Create rails project directory and Move there
WORKDIR /home/${USER_NAME}/api


# --- Final stage for development ---
FROM base-common AS development
ARG DEV_API_PORT
# puma references PORT
ENV PORT=$DEV_API_PORT
# Install packages needed for development
RUN apt-get update -qq \
    && \
    apt-get install \
      --no-install-recommends -y \
      build-essential \
      git \
      libpq-dev \
      pkg-config
# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install
# Startup configurations
COPY --chown=$USER_NAME:$GROUP_NAME ./bin ./bin
ENTRYPOINT [ "./bin/docker-entrypoint.dev.sh" ]
USER $USER_NAME:$GROUP_NAME
CMD ["sh", "-c", "./bin/rails server --port ${PORT} --binding 0.0.0.0"]


# --- Base stage for production ---
FROM base-common AS base-production
# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_WITHOUT="development"


# --- Build stage for production ---
FROM base-production AS build
# Install packages needed to build gems
RUN apt-get update -qq \
    && \
    apt-get install \
      --no-install-recommends -y \
      build-essential \
      git \
      libpq-dev \
      pkg-config \
    && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives
# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ ${BUNDLE_PATH}/ruby/*/cache ${BUNDLE_PATH}/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile
# Copy application code
COPY . .
# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/


# --- Final stage for production ---
FROM base-production AS production
ARG PROD_API_PORT
ENV PORT=$PROD_API_PORT
# Copy built artifacts
#   * gems in $BUNDLE_PATH
COPY --from=build $BUNDLE_PATH $BUNDLE_PATH
#   * precompiled application code
COPY --from=build /home/${USER_NAME}/api /home/${USER_NAME}/api
# Give container users write permission to a minimum number of directories
RUN chown -R $USER_NAME:$GROUP_NAME db log tmp
# Startup configurations
ENTRYPOINT ["./bin/docker-entrypoint"]
EXPOSE $PROD_API_PORT
USER $USER_NAME:$GROUP_NAME
CMD ["./bin/rails", "server"]
