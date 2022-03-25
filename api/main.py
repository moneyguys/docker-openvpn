import os
import subprocess
from loguru import logger
from pydantic import BaseModel
from fastapi import FastAPI


class CertificateCreateRequest(BaseModel):
    certificate_user: str
    expired_in: int = None


def create_certificate_for_user(certificate_user: str,
                                expired_in: int = None):
    cert_path, err = None, None
    add_user_cmd = f'easyrsa build-client-full {certificate_user} nopass'
    user_cert_folder = '/etc/openvpn/user-certs/'
    cert_filename = f'{certificate_user}.ovpn'
    user_cert_abs_path = os.path.join(user_cert_folder, cert_filename)
    generate_cert = f'ovpn_getclient {certificate_user} >  {user_cert_abs_path}'
    final_cmd = ";".join([add_user_cmd, generate_cert])
    pipe = subprocess.Popen(final_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    res = pipe.communicate()
    retcode = pipe.returncode
    logger.debug(f"res={res}, retcode={retcode}")
    if retcode != 0:
        error_text = res[-1]
        return cert_path, error_text
    return user_cert_abs_path, err


app = FastAPI()


@app.post("/create_user_certificate")
def read_root(certificate_create_request: CertificateCreateRequest):
    certificate_user = certificate_create_request.certificate_user
    expired_in = certificate_create_request.expired_in
    cert_path, err = create_certificate_for_user(certificate_user, expired_in)
    return {"certificate_user": certificate_user, "expired_in": expired_in, 'cert_path': cert_path, 'err':err}
