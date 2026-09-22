from pydantic import BaseModel, EmailStr


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str
    full_name: str
    phone_number: str
    role: str = "patient"


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class GoogleLoginRequest(BaseModel):
    id_token: str
    provider: str = "google"


class ResetPasswordRequest(BaseModel):
    email: EmailStr


class UpdatePasswordRequest(BaseModel):
    new_password: str