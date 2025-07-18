import openai
import os
from dotenv import load_dotenv

load_dotenv()
openai.api_key = os.getenv('OPENAI_API_KEY')

def tailor_resume(resume, job_desc, model="gpt-4o"):
    prompt = f"""
You are an expert resume writer.
Given this resume and job description, tailor the resume to maximize matching keywords and relevance for the job.

Resume:
{resume}

Job Description:
{job_desc}

Return only the tailored resume.
"""
    response = openai.chat.completions.create(
        model=model,
        messages=[{'role': 'user', 'content': prompt}],
        max_tokens=1800,
        temperature=0.4,
    )
    return response.choices[0].message.content.strip()

