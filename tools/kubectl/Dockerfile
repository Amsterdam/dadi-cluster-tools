# Base image for kubectl
FROM rancher/kubectl:v1.33.5

# Each project should define it's own copy and run logic
COPY --chown=kubectl:kubectl ./scripts/brp-proxy ~/scripts/

# Default ENTRYPOINT and CMD for the base image
ENTRYPOINT ["/bin/kubectl"]
CMD ["help"]