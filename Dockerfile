ARG PIPELINE
FROM astroconda/pipeline:${PIPELINE}
LABEL maintainer="jhunk@stsci.edu" \
      vendor="Space Telescope Science Institute"

WORKDIR "${TOOLCHAIN_BUILD}"

COPY scripts/ ${TOOLCHAIN_BUILD}/bin
COPY etc/ ${TOOLCHAIN_BUILD}/etc

USER "${USER_ACCT}"

RUN sudo chown -R ${USER_ACCT}: ${TOOLCHAIN_BUILD} \
    && bin/build.sh \
    && sudo rm -rf "${TOOLCHAIN_BUILD}"

WORKDIR "${USER_HOME}"

EXPOSE 8888
ENTRYPOINT ["tini", "-g", "--"]
CMD ["start.sh"]
