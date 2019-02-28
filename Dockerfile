ARG HUB
ARG PIPELINE
FROM ${HUB}/datb-tc-pipeline:${PIPELINE}
LABEL maintainer="jhunk@stsci.edu" \
      vendor="Space Telescope Science Institute"

ARG NB_USER="jovyan"
ARG NB_UID="1100"
ARG NB_GID="110"

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
# Create jovyan user with UID=1100 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    chmod g+w /etc/passwd && \
    fix-permissions $NB_HOME && \
    echo "root ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/rewt

# Begin toolchain image-specific steps
USER "${USER_ACCT}"

RUN sudo chown -R ${USER_ACCT}: ${TOOLCHAIN_BUILD} \
    && bin/build.sh \
    && sudo rm -rf "${TOOLCHAIN_BUILD}"

# Begin jupyterhub specific steps
ENV HOME="${NB_HOME}"
USER "${NB_UID}"

# Setup work directory for backward-compatibility
RUN mkdir /home/$NB_USER/work && \
    fix-permissions /home/$NB_USER && \
    jupyter notebook --generate-config

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
