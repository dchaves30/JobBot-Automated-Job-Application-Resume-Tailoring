from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from models import User, JobPreference, ApplicationLog, ResumeTailorRequest
from db import db
from openai_utils import tailor_resume

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=['http://localhost:3000'],
    allow_methods=['*'],
    allow_headers=['*'],
)

@app.post('/register')
def register(user: User):
    if db.users.find_one({'email': user.email}):
        raise HTTPException(status_code=409, detail='User already exists')
    db.users.insert_one(user.dict())
    return {'msg': 'User registered'}

@app.post('/login')
def login(user: User):
    if db.users.find_one(user.dict()):
        return {'msg': 'Login successful'}
    raise HTTPException(status_code=401, detail='Invalid credentials')

@app.post('/preferences')
def set_preferences(pref: JobPreference, user_email: str):
    db.preferences.update_one({'email': user_email}, {'$set': pref.dict()}, upsert=True)
    return {'msg': 'Preferences updated'}

@app.get('/applications')
def get_applications(user_email: str):
    logs = list(db.applications.find({'user_email': user_email}, {'_id': 0}))
    return logs

@app.post('/applications')
def log_application(log: ApplicationLog):
    db.applications.insert_one(log.dict())
    return {'msg': 'Logged'}

@app.post('/tailor_resume')
def api_tailor_resume(req: ResumeTailorRequest):
    tailored = tailor_resume(req.resume, req.job_desc)
    return {'tailored_resume': tailored}
