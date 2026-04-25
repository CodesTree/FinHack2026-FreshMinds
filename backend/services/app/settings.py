from typing import Literal

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    environment: Literal["local", "staging", "production"] = "local"
    aws_region: str = "ap-southeast-1"
    sagemaker_endpoint_name: str = ""
    use_sagemaker: bool = False
