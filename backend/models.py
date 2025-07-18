from pydantic import BaseModel
from typing import List

class User(BaseModel):
    email: str
    password: str

class JobPreference(BaseModel):
    job_title: str
    location: str
    keywords: List[str]

class ApplicationLog(BaseModel):
    job_title: str
    company: str
    portal: str
    status: str
    applied_on: str
    user_email: str

class ResumeTailorRequest(BaseModel):
    resume: str
    job_desc: str
