# Dockerfile definition for the Ubuntu based EspressIf ESP32-IDF
# References:
# - https://docs.github.com/en/actions/creating-actions/creating-a-docker-container-action:
# - https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/linux-macos-setup.html
FROM ubuntu:20.04

# This is required to ensure that tzdata installs based on the defaulted timezone of UTC.
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# GitHub actions set ENV values instead of ARG values.
ENV RELEASE=v5.1
ENV HASH=123456

ENV DIRNAME=/opt/espressif-idf
ENV FILEPREFIX=esp-idf-release
ENV URLPREFIX=https://github.com/espressif/esp-idf/archive/refs/heads/release

# We also add "curl" to the list below because we need it to download the ZIPfile.
RUN \
    echo "Installing toolchain prerequisites..." \
    && apt --yes update \
    && apt --yes install \
        wget flex bison gperf python3 python3-pip \
        python3-venv cmake ninja-build ccache \
        libffi-dev libssl-dev dfu-util libusb-1.0-0 \
        curl

# Note the need for the semi-colons in the 'if' test below.
RUN \
    echo "Downloading the EspressIF IDE..." \
    && ESPTEMP=$(mktemp --directory espressif.XXXXXX) \
    && echo "Temporary download directory: ${ESPTEMP}." \
    && PUSHD=${PWD} \
    && cd ${ESPTEMP} \
    && curl \
        --location \
        --output ${FILEPREFIX}-${RELEASE}.zip \
        ${URLPREFIX}/${RELEASE}.zip \
    && echo "Debug 1" \
    && cd ${PUSHD} \
    && echo "Debug 2" \
    && REMOTE_HASH=$(sha256sum ${ESPTEMP}/${FILEPREFIX}-${RELEASE}.zip) \
    && echo "Debug 3" \
    && if [[ "${REMOTE_HASH}" != "${HASH}" ]]; \
       then \
           echo "EspressIF ZIPfile hash, '${REMOTE_HASH}',' has changed!"; \
           exit 1; \
       fi

RUN \
    echo "Extracting the EspressIF IDE..." \
    && mkdir --parents ${DIRNAME} \
    && unzip ${ESPTEMP}/${FILEPREFIX}-${RELEASE}.zip --directory ${DIRNAME} \
    && echo "Deleting the temporary ZIPfile and directory..." \
    && rm --force --recursive ${ESPTEMP}

RUN \
    echo "Installing the EspressIF IDF tools..." \
    && pushd ${DIRNAME}/esp/esp-idf || exit 1 \
    && ./install.sh esp32 \
    && popd || exit 1 \
    && echo "Done."
