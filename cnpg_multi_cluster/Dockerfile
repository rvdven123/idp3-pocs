FROM alpine:3.20

ARG KUBECTL_VERSION=v1.34.1
ARG KIND_VERSION=v0.32.0
ARG SUBCTL_VERSION=0.23.1
ARG HELM_VERSION=v3.15.4
ARG YQ_VERSION=v4.44.3

RUN apk add --no-cache \
    bash \
    curl \
    ca-certificates \
    git \
    make \
    jq \
    openssl \
    iproute2 \
    bind-tools \
    docker-cli \
    tar \
    gzip \
    coreutils \
    util-linux \
    xz \
    tar 

RUN curl -L "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
      -o /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/kubectl

# RUN curl -L "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" \
#       -o /tmp/helm.tar.gz \
#  && tar -xzf /tmp/helm.tar.gz -C /tmp \
#  && mv /tmp/linux-amd64/helm /usr/local/bin/helm \
#  && chmod +x /usr/local/bin/helm \
#  && rm -rf /tmp/helm.tar.gz /tmp/linux-amd64

RUN curl -L "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" \
      -o /usr/local/bin/yq \
 && chmod +x /usr/local/bin/yq

RUN curl -L "https://github.com/submariner-io/releases/releases/download/v${SUBCTL_VERSION}/subctl-v${SUBCTL_VERSION}-linux-amd64.tar.xz" \
      -o /tmp/subctl.tar.xz \
 && tar -xJf /tmp/subctl.tar.xz -C /tmp \
 && mv /tmp/subctl-v${SUBCTL_VERSION}/subctl /usr/local/bin/subctl \
 && chmod +x /usr/local/bin/subctl \
 && rm -rf /tmp/subctl.tar.xz /tmp/subctl-v${SUBCTL_VERSION}

RUN curl -fL "https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64" \
      -o /usr/local/bin/kind \
 && chmod +x /usr/local/bin/kind

RUN curl -LO https://github.com/stern/stern/releases/download/v1.34.0/stern_1.34.0_linux_amd64.tar.gz \
&& tar -xzf stern_1.34.0_linux_amd64.tar.gz \
&& mv stern /usr/local/bin/ 

WORKDIR /work

CMD ["/bin/bash"]