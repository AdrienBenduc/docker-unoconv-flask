FROM python:3.7.4-alpine3.10

ENV LC_ALL=en_US.UTF-8 \
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US.UTF-8 \
	UNO_URL=https://raw.githubusercontent.com/dagwieers/unoconv/master/unoconv

# copy unconv files
COPY ./requirements.txt /tmp/requirements.txt

RUN apk update

RUN apk add --no-cache \
        --virtual .build-deps \
        gcc \
        g++ \
        linux-headers \
        libc-dev \
    && apk add --no-cache \
        curl \
        libreoffice-common \
        libreoffice-writer \
        libreoffice-calc \
        libreoffice-impress \
        ttf-droid-nonlatin \
        ttf-droid \
        ttf-dejavu \
        ttf-freefont \
        ttf-liberation \
    && curl -Ls $UNO_URL -o /bin/unoconv \
    && chmod +x /bin/unoconv \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && pip install pip --upgrade \
    && pip install -r /tmp/requirements.txt \
    && apk del curl \
    && rm -rf /var/cache/apk/* \
    && rm -rf /root/.cache/ \
    && rm -rf /tmp/requirements.txt \
    && apk del .build-deps

RUN apk upgrade

# copy unconv files
COPY . /unoconv

RUN rm -rf /unoconv/.git

WORKDIR /unoconv

EXPOSE 5000

RUN addgroup unoconv && adduser \
    -D \
    -g "" \
    -G unoconv \
    -H \
    -u 1003 \
    coog

RUN mkdir -p /home/coog/.config/
RUN chmod -R 777 /home/coog/.config/

RUN touch /var/log/unoconv.log
RUN touch /var/log/unoconv.log

RUN chown coog:unoconv /var/log/unoconv.log
RUN chown -R coog:unoconv /home/coog/

ENTRYPOINT circusd circus.ini
