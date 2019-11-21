#
# Presidio Dev Container
#   Build Args:
#     PY_VER: The python version to use (major.minor)
#     GO_VER: The go version to use (major.minor.patch)
#     PIP_VER: The pip version to use (major)
#     RE2_VER: The re2 version to use (year-month-day)
#
#   Mount points:
#     /workspaces/src/presidio: The root project dir
#     /mnt/pipenv-cache: The pipenv cache
#     /mnt/dep-cache: The go-dep cache
#
FROM debian:stable-slim

ARG PY_VER="3.7"
ARG PIP_VER="3"

# Install as much as possible via apt-get
RUN apt-get update \
  && apt-get install -y \
  curl \
  python${PY_VER} \
  python${PIP_VER}-pip \
  tesseract-ocr \
  libtesseract-dev \
  dos2unix \
  make \
  apt-transport-https \
  ca-certificates \
  gnupg2 \
  software-properties-common \
  git

# GO recommends installing their source via direct download
# We do so, and configure the system to be aware of it
ARG GO_VER="1.13.4"
RUN curl https://dl.google.com/go/go${GO_VER}.linux-amd64.tar.gz | tar -xz -C /usr/local 
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOROOT="/usr/local/go"

# go-dep (for dep mananagement) recommends installing via apt
# We do so
RUN apt-get install -y go-dep

# gometalinter (used for tests/linting)
RUN cd /usr/local/go \
  && curl -L https://git.io/vp6lP | sh

# Presidio optionally depends on re2
# We install and build it
ARG RE2_VER="2019-11-01"
RUN mkdir /usr/local/re2 \
  && curl -LJ https://github.com/google/re2/archive/${RE2_VER}.tar.gz | tar -xz -C /usr/local/re2 --strip-components 1 \
  && cd /usr/local/re2 \
  && make install

# Presidio-analyzer uses pipenv to manage deps
# We install it, and a snapshot of the deps
RUN pip3 install pipenv
COPY ./presidio-analyzer/Pipfile.lock /tmp/Pipfile.lock
COPY ./presidio-analyzer/Pipfile /tmp/Pipfile
RUN tmp_dir=$(mktemp -d) \
  && cp /tmp/Pipfile* $tmp_dir \
  && cd $tmp_dir \
  && echo "This will take a while..." \
  && pipenv install --system --dev --sequential \
  && echo "Done." \
  && rm -rf $tmp_dir

# Install docker (so we can docker in docker)
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
  && add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable" \
  && apt-get update \
  && apt-get install -y docker-ce-cli

# Cleanup apt lists (no longer needed, as we've finished installs)
RUN rm -rf /var/lib/apt/lists/*

# Expect that presidio source is mounted
VOLUME [ "/workspaces/src/presidio" ]
ENV GOPATH="/workspaces"

# We also pull in our entrypoint configuration
# This will manage things that can only be done at runtime
COPY ./.devcontainer/entrypoint.sh /entrypoint.sh
RUN dos2unix /entrypoint.sh \
  && chmod +x /entrypoint.sh

# Expect that we have tool cache dirs mounted
VOLUME [ "/mnt/pipenv-cache" ]
VOLUME [ "/mnt/dep-cache" ]
ENV DEPCACHEDIR="/mnt/dep-cache"
ENV PIPENV_CACHE_DIR="/mnt/pipenv-cache"

ENTRYPOINT [ "/entrypoint.sh" ]
