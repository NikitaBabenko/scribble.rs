# Official v0.9.14 binary, source 000312758ce98ca6280880ea5ab57d28d1215a2e.
# This image packages that release; it does not compile this fork's master.
FROM biosmarcel/scribble.rs@sha256:9d1d651538de3a95e2d318f134ad9c1e9740945cb87835ac7c1cdfbd82a9c775 AS game
FROM nginx@sha256:47928bf67eb62a1863cb08d9ecb52d3e704304ba614eaee17884204677702951
COPY --from=game --chmod=0555 /scribblers /usr/local/bin/scribblers
COPY --chmod=0444 vibenest/nginx.conf /etc/nginx/nginx.conf
COPY --chmod=0555 vibenest/start.sh /usr/local/bin/start-scribble
ENV LOBBY_SETTING_DEFAULTS_PUBLIC=false \
    LOBBY_SETTING_DEFAULTS_MAX_PLAYERS=8 \
    LOBBY_SETTING_BOUNDS_MAX_MAX_PLAYERS=8 \
    LOBBY_SETTING_DEFAULTS_CLIENTS_PER_IP_LIMIT=8 \
    LOBBY_SETTING_BOUNDS_MAX_CLIENTS_PER_IP_LIMIT=8
USER 101:101
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 CMD ["/bin/busybox", "wget", "-q", "-T", "3", "-O", "/dev/null", "http://127.0.0.1:8080/health"]
ENTRYPOINT ["/usr/local/bin/start-scribble"]
