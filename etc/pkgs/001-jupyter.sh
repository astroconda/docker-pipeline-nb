#!/bin/bash
set -x

pip install --upgrade --progress-bar=off \
    notebook==5.7.2 \
    jupyterhub==0.9.4 \
    jupyterlab==0.35.4

jupyter labextension install @jupyterlab/hub-extension@^0.12.0
jupyter notebook --generate-config -y

# Clean up
npm cache clean --force
rm -rf ${TOOLCHAIN}/share/jupyter/lab/staging
rm -rf /home/${USER_ACCT}/.cache/yarn
