# --- Create directories ---
New-Item -ItemType Directory -Force -Path .\backend | Out-Null
New-Item -ItemType Directory -Force -Path .\frontend\src | Out-Null
New-Item -ItemType Directory -Force -Path .\bot | Out-Null

# --- Backend files ---
Set-Content .\backend\requirements.txt @"
fastapi
pymongo
uvicorn
python-dotenv
openai
"@

Set-Content .\backend\.env @"
MONGODB_URI=mongodb://mongo:27017
OPENAI_API_KEY=<your key here>
"@

Set-Content .\backend\db.py @"
import os
from pymongo import MongoClient
from dotenv import load_dotenv

load_dotenv()
client = MongoClient(os.environ['MONGODB_URI'])
db = client['jobbot']
"@

Set-Content .\backend\models.py @"
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
"@

Set-Content .\backend\openai_utils.py @"
import openai
import os
from dotenv import load_dotenv

load_dotenv()
openai.api_key = os.getenv('OPENAI_API_KEY')

def tailor_resume(resume, job_desc, model='gpt-4o'):
    prompt = f'''
You are an expert resume writer.
Given this resume and job description, tailor the resume to maximize matching keywords and relevance for the job.

Resume:
{resume}

Job Description:
{job_desc}

Return only the tailored resume.
'''
    response = openai.chat.completions.create(
        model=model,
        messages=[{{'role': 'user', 'content': prompt}}],
        max_tokens=1800,
        temperature=0.4,
    )
    return response.choices[0].message.content.strip()
"@

Set-Content .\backend\main.py @"
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
    if db.users.find_one({{'email': user.email}}):
        raise HTTPException(status_code=409, detail='User already exists')
    db.users.insert_one(user.dict())
    return {{'msg': 'User registered'}}

@app.post('/login')
def login(user: User):
    if db.users.find_one(user.dict()):
        return {{'msg': 'Login successful'}}
    raise HTTPException(status_code=401, detail='Invalid credentials')

@app.post('/preferences')
def set_preferences(pref: JobPreference, user_email: str):
    db.preferences.update_one({{'email': user_email}}, {{'$set': pref.dict()}}, upsert=True)
    return {{'msg': 'Preferences updated'}}

@app.get('/applications')
def get_applications(user_email: str):
    logs = list(db.applications.find({{'user_email': user_email}}, {{'_id': 0}}))
    return logs

@app.post('/applications')
def log_application(log: ApplicationLog):
    db.applications.insert_one(log.dict())
    return {{'msg': 'Logged'}}

@app.post('/tailor_resume')
def api_tailor_resume(req: ResumeTailorRequest):
    tailored = tailor_resume(req.resume, req.job_desc)
    return {{'tailored_resume': tailored}}
"@

Set-Content .\backend\Dockerfile @"
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ['uvicorn', 'main:app', '--host', '0.0.0.0', '--port', '8000']
"@

# --- Frontend files ---
Set-Content .\frontend\package.json @"
{
  'name': 'jobbot-frontend',
  'version': '1.0.0',
  'private': true,
  'dependencies': {
    'react': '^18.2.0',
    'react-dom': '^18.2.0'
  },
  'scripts': {
    'start': 'npx serve -s build -l 3000'
  }
}
"@

Set-Content .\frontend\tailwind.config.js @"
module.exports = {
  content: ['./src/**/*.{js,jsx,ts,tsx}'],
  theme: { extend: {} },
  plugins: [],
}
"@

Set-Content .\frontend\src\App.js @"
import React, { useState } from 'react';

export default function App() {
  const [email, setEmail] = useState('');
  const [jobTitle, setJobTitle] = useState('');
  const [location, setLocation] = useState('');
  const [keywords, setKeywords] = useState('');
  const [resume, setResume] = useState('');
  const [jobDesc, setJobDesc] = useState('');
  const [tailoredResume, setTailoredResume] = useState('');
  const [applications, setApplications] = useState([]);

  const fetchApplications = async () => {
    const res = await fetch(`http://localhost:8000/applications?user_email=${email}`);
    const data = await res.json();
    setApplications(data);
  };

  const tailorResume = async () => {
    const res = await fetch('http://localhost:8000/tailor_resume', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ resume, job_desc: jobDesc }),
    });
    const data = await res.json();
    setTailoredResume(data.tailored_resume);
  };

  return (
    <div className='max-w-3xl mx-auto p-8'>
      <h1 className='text-2xl font-bold mb-4'>Job Application Bot Dashboard</h1>
      <div className='mb-8 p-4 border rounded'>
        <h2 className='font-semibold mb-2'>Set Preferences</h2>
        <input className='border p-2 mr-2' placeholder='Email' value={email} onChange={e => setEmail(e.target.value)} />
        <input className='border p-2 mr-2' placeholder='Job Title' value={jobTitle} onChange={e => setJobTitle(e.target.value)} />
        <input className='border p-2 mr-2' placeholder='Location' value={location} onChange={e => setLocation(e.target.value)} />
        <input className='border p-2 mr-2' placeholder='Keywords' value={keywords} onChange={e => setKeywords(e.target.value)} />
        <button className='bg-blue-500 text-white px-4 py-2 rounded'
          onClick={async () => {
            await fetch('http://localhost:8000/preferences?user_email=' + email, {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ job_title: jobTitle, location, keywords: keywords.split(',') }),
            });
            alert('Preferences saved!');
          }}
        >Save Preferences</button>
      </div>
      <div className='mb-8 p-4 border rounded'>
        <h2 className='font-semibold mb-2'>Tailor Resume</h2>
        <textarea className='w-full border p-2 mb-2' rows={4} placeholder='Paste resume here' value={resume} onChange={e => setResume(e.target.value)} />
        <textarea className='w-full border p-2 mb-2' rows={4} placeholder='Paste job description here' value={jobDesc} onChange={e => setJobDesc(e.target.value)} />
        <button className='bg-green-600 text-white px-3 py-1 rounded' onClick={tailorResume}>Tailor Resume</button>
        {tailoredResume && (
          <div className='mt-4'>
            <h3 className='font-semibold'>Tailored Resume:</h3>
            <pre className='bg-gray-100 p-2'>{tailoredResume}</pre>
          </div>
        )}
      </div>
      <div className='mb-8 p-4 border rounded'>
        <h2 className='font-semibold mb-2'>Application Log</h2>
        <button className='bg-indigo-600 text-white px-3 py-1 rounded mb-2' onClick={fetchApplications}>Fetch Applications</button>
        <ul>
          {applications.map((a, i) => (
            <li key={i} className='border-b py-2'>
              <strong>{a.job_title}</strong> @ {a.company} ({a.portal}) - {a.status} [{a.applied_on}]
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
"@

Set-Content .\frontend\Dockerfile @"
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
EXPOSE 3000
CMD ['npm', 'start']
"@

# --- Bot ---
Set-Content .\bot\apply_bot.py @"
import asyncio
from playwright.async_api import async_playwright

async def apply_to_job(job_url, resume_path, email, password):
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=False)
        context = await browser.new_context()
        page = await context.new_page()
        await page.goto(job_url)
        # Add selectors as needed for your chosen job board
        # await page.fill('input[name="email"]', email)
        # await page.fill('input[name="password"]', password)
        # await page.click('button[type="submit"]')
        # await page.set_input_files('input[type="file"]', resume_path)
        await browser.close()
# Example usage:
# asyncio.run(apply_to_job('https://jobs.example.com/job123', 'resume.pdf', 'email', 'password'))
"@

Set-Content .\docker-compose.yml @"
version: '3.8'
services:
  mongo:
    image: mongo:5
    restart: always
    ports:
      - '27017:27017'
    volumes:
      - mongo-data:/data/db

  backend:
    build: ./backend
    volumes:
      - ./backend:/app
    env_file:
      - ./backend/.env
    depends_on:
      - mongo
    ports:
      - '8000:8000'

  frontend:
    build: ./frontend
    ports:
      - '3000:3000'
    depends_on:
      - backend

volumes:
  mongo-data:
"@

Write-Host ''
Write-Host '------------------------------------------'
Write-Host '🎉  Project created in current directory!'
Write-Host 'Next steps:'
Write-Host '1. Add your real OpenAI API key in backend\.env'
Write-Host '2. In this directory, run: docker-compose up --build'
Write-Host '3. Visit http://localhost:3000 (frontend) and http://localhost:8000/docs (API docs)'
Write-Host '------------------------------------------'
