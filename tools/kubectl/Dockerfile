# Base image for kubectl
FROM rancher/kubectl:v1.33.5 AS builder

FROM debian:13.1-slim

RUN useradd -u 1000 -U -m kubectl
WORKDIR /bin

COPY --from=builder --chown=kubectl:kubectl /bin/kubectl /bin/kubectl
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# Each project should define it's own copy and run logic
COPY --chown=kubectl:kubectl ./scripts/ /scripts/
RUN chmod -R +x /scripts/**/*

USER kubectl

# Default ENTRYPOINT and CMD for the base image
ENTRYPOINT ["bash"]
CMD ["help"]