# Original credit: https://github.com/jpetazzo/dockvpn

# Smallest base image
FROM python:3.7-alpine

LABEL maintainer="moneyguys"

# Testing: pamtester
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    apk add --update openvpn iptables bash easy-rsa openvpn-auth-pam google-authenticator pamtester libqrencode && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

# Needed by scripts
ENV OPENVPN=/etc/openvpn
ENV EASYRSA=/usr/share/easy-rsa \
    EASYRSA_CRL_DAYS=3650 \
    EASYRSA_PKI=$OPENVPN/pki

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp
EXPOSE 8080/tcp

# Add run python api above openvpn
COPY ./api/requirements.txt /code/requirements.txt
COPY ./api/main.py /code/main.py
RUN pip3 install -r /code/requirements.txt

  nohup python3 telegram_researcher/bot.py > output.log &
RUN "nohup python3 -m uvicorn --app-dir ./code main:app --host 0.0.0.0 --port 8080 > /code/output.log &"
CMD openvpn_run


ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/
