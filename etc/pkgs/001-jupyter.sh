#!/bin/bash
set -x

pip install --upgrade --progress-bar=off \
    notebook==5.7.2 \
    jupyterhub==0.9.4 \
    jupyterlab==0.35.4

# Workaround for kernel+WebSocket failure
# See: https://github.com/jupyter/notebook/issues/4399
pip install --progress-bar=off  tornado==5.1.1

jupyter labextension install @jupyterlab/hub-extension@^0.12.0
jupyter notebook --generate-config -y

# Clean up
npm cache clean --force
rm -rf ${TOOLCHAIN}/share/jupyter/lab/staging
rm -rf /home/${USER_ACCT}/.cache/yarn
