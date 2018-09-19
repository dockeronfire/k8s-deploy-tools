FROM frolvlad/alpine-glibc:latest

LABEL maintainer="Constantine Karnaukhov <genteelknight@gmail.com>"

# Install dependencies
ENV BUILD_DEPS='tar gzip' \
	RUN_DEPS='curl ca-certificates gettext'

RUN apk --no-cache add $BUILD_DEPS $RUN_DEPS

# Install kubectl
ENV KUBECTL_VERSION=v1.11.3

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
	chmod +x ./kubectl && \
	mv ./kubectl /usr/local/bin/

# Install OpenShift CLI
ENV OC_VERSION=v3.10.0 \
	OC_TAG_SHA=dd10d17

RUN curl -sLo /tmp/oc.tar.gz https://github.com/openshift/origin/releases/download/${OC_VERSION}/openshift-origin-client-tools-${OC_VERSION}-${OC_TAG_SHA}-linux-64bit.tar.gz && \
	tar xzvf /tmp/oc.tar.gz -C /tmp/ && \
	mv /tmp/openshift-origin-client-tools-${OC_VERSION}-${OC_TAG_SHA}-linux-64bit/oc /usr/local/bin/ && \
	rm -rf /tmp/oc.tar.gz /tmp/openshift-origin-client-tools-${OC_VERSION}-${OC_TAG_SHA}-linux-64bit

# Install istioctl
ENV ISTIO_VERSION=1.0.2

RUN curl -sLo /tmp/istio.tar.gz https://github.com/istio/istio/releases/download/${ISTIO_VERSION}/istio-${ISTIO_VERSION}-linux.tar.gz && \
	tar xzvf /tmp/istio.tar.gz -C /tmp/ && \
	mv /tmp/istio-${ISTIO_VERSION}/bin/istioctl /usr/local/bin/ && \
	rm -rf /tmp/istio.tar.gz /tmp/istio-${ISTIO_VERSION}

# Clean cache
RUN apk del $BUILD_DEPS

CMD ["sh"]
