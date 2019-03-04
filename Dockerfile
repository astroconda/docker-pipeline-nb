ARG HUB
ARG PIPELINE
FROM ${HUB}/datb-tc-pipeline:${PIPELINE}
LABEL maintainer="jhunk@stsci.edu" \
      vendor="Space Telescope Science Institute"

ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"

USER root
WORKDIR "${TOOLCHAIN_BUILD}"

COPY scripts/build.sh ${TOOLCHAIN_BUILD}/bin/
COPY etc/ ${TOOLCHAIN_BUILD}/etc

ENV NB_USER="${NB_USER}" \
    NB_UID="${NB_UID}" \
    NB_GID="${NB_GID}" \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
ENV NB_HOME="/home/${NB_USER}"

ADD scripts/fix-permissions /usr/local/bin/fix-permissions

# Begin toolchain image-specific steps
USER "${USER_ACCT}"

RUN sudo chown -R ${USER_ACCT}: ${TOOLCHAIN_BUILD} \
    && bin/build.sh \
    && sudo rm -rf "${TOOLCHAIN_BUILD}"

# Replace user 'developer' with 'jovyan'
USER root
RUN mv ${USER_HOME} ${NB_HOME} \
    && usermod -l ${NB_USER} ${USER_ACCT} \
    && usermod -d ${NB_HOME} -g ${NB_GID} -G ${USER_ACCT} ${NB_USER} \
    && chown -R ${NB_USER}:${NB_UID} ${NB_HOME} \
    && chmod g+w /etc/passwd \
    && fix-permissions ${NB_HOME}

# Begin jupyterhub specific steps
ENV HOME="${NB_HOME}"
USER "${NB_UID}"

# Setup work directory for backward-compatibility
RUN mkdir ${NB_HOME}/work \
    && fix-permissions ${NB_HOME}

USER root

EXPOSE 8888
WORKDIR "${HOME}"

ENTRYPOINT ["tini", "-g", "--"]
CMD ["start-notebook.sh"]

COPY scripts/start.sh /usr/local/bin/
COPY scripts/start-notebook.sh /usr/local/bin/
COPY scripts/start-singleuser.sh /usr/local/bin/
COPY scripts/jupyter_notebook_config.py /etc/jupyter/
RUN fix-permissions /etc/jupyter/

USER "${NB_UID}"
