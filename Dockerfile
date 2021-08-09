# Docker image for behave and other Python-based SBE/BDD tools.
#
# URL: https://github.com/William-Yeh/docker-behave
#
# References: 
#   - https://eshlox.net/2016/11/22/dockerize-behave-selenium-tests/
#   - https://gist.github.com/ziadoz/3e8ab7e944d02fe872c3454d17af31a5
#
# For CJK font: https://github.com/elgalu/docker-selenium/pull/153
#
#
# Version     1.2.2
#


# pull base image
FROM python:3.9.6-slim-buster

ENV CHROME_DRIVER_VERSION 92.0.4515.107
ENV CHROME_DRIVER_TARBALL http://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip

RUN \
    echo "==> Install common stuff missing from the slim base image..."   && \
    apt-get update            && \
    apt-get install -y --no-install-recommends \
        gnupg   \
        dirmngr \
        wget    \
        ca-certificates               && \
        rm -rf /var/lib/apt/lists/*

RUN \
    echo "==> Add Google repo for Chrome..."   && \
    wget -q -O- https://dl.google.com/linux/linux_signing_key.pub | apt-key add -  && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google.list  && \
    \
    \
    echo "==> Install prerequisite stuff..."   && \
    apt-get update            && \
    apt-get install -y --no-install-recommends \
        python3-dev              \
        python3-pip              \
        xvfb                     \
        libfontconfig            \
        libfreetype6             \
        xfonts-scalable          \
        fonts-liberation         \
        fonts-noto-cjk           \
        google-chrome-stable

RUN \
    echo "==> Install ChromeDriver..."   && \
    wget -qO- $CHROME_DRIVER_TARBALL | zcat > /usr/local/bin/chromedriver  && \
    chown root:root /usr/local/bin/chromedriver  && \
    chmod 0755 /usr/local/bin/chromedriver

RUN \
    echo "==> Install useful Python stuff..."   && \
    pip3 install --no-cache-dir \
        requests                \
        unittest-xml-reporting  \
        nose                    \
        mockito                 \
        pyshould

RUN \
    echo "==> Install behave and related stuff..."   && \
    pip3 install --no-cache-dir \
        behave                  \
        selenium                \
        elementium              \
        capybara-py             \
        xvfbwrapper             \
        virtualenv

RUN \
    echo "==> Clean up..."      && \
    rm -rf /var/lib/apt/lists/*


ENV PATH /usr/lib/chromium/:$PATH

WORKDIR    /behave
ENV        REQUIREMENTS_PATH  /behave/requirements.txt

COPY       wrapper.sh  /tmp
ENTRYPOINT ["/tmp/wrapper.sh"]
