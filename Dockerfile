# Dockerfile definition for the Ubuntu based EspressIf ESP32-IDF
# References:
# - https://docs.github.com/en/actions/creating-actions/creating-a-docker-container-action:
# - https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/linux-macos-setup.html
FROM ubuntu:20.04

# GitHub actions set ENV values instead of ARG values.
ENV RELEASE=v5.1
ENV HASH=123456

ENV DIRNAME=/opt/espressif-idf
ENV FILEPREFIX=esp-ide-release
ENV URLPREFIX=https://github.com/espressif/esp-idf/archive/refs/heads/release

RUN \
    echo "Installing toolchain prerequisites..." \
    && apt --yes update \
    && apt --yes install \
        wget flex bison gperf python3 python3-pip \
        python3-venv cmake ninja-build ccache \
        libffi-dev libssl-dev dfu-util libusb-1.0-0

RUN \
    echo "Downloading the EspressIF IDE..." \
    && ESPTEMP=$(mktemp espressif.XXXXXX) \
    && echo "Temporary download directory: ${ESPTEMP}." \
    && curl \
        --location \
        --output-dir ${ESPTEMP} \
        --output ${FILEPREFIX}-${RELEASE}.zip \
        ${URLPREFIX}/$RELEASE.zip \
    && REMOTE_HASH=$(sha256sum ${ESPTEMP}/${FILEPREFIX}-${RELEASE}.zip) \
    && if [[ "${REMOTE_HASH}" != "${HASH}" ]] \
       then \
           echo "EspressIF ZIPfile hash has changed!" \
           exit 1 \
       fi

RUN \
    echo "Extracting the EspressIF IDE..." \
    && mkdir --parents ${DIRNAME} \
    && unzip ${ESPTEMP}/${FILEPREFIX}-$RELEASE.zip -d ${DIRNAME} \
    && echo "Deleting the temporary ZIPfile and directory..." \
    && rm --force --recursive ${ESPTEMP}

RUN \
    echo "Installing the EspressIF IDF tools..." \
    && pushd ${DIRNAME}/esp/esp-idf || exit 1 \
    && ./install.sh esp32 \
    && popd || exit 1 \
    && echo "Done."
