# 🤖 JobBot: Automated Job Application & Resume Tailoring

JobBot automates your job search: instantly tailor your resume for each job description with GPT-4, track your job applications, and (optionally) auto-apply using a browser bot.

---

## Features

- **AI Resume Tailoring:** Customize your resume for any job description using OpenAI.
- **Job Preferences:** Save and edit your job search filters.
- **Application Log:** Track which jobs you applied to, when, and where.
- **React Dashboard:** Clean, simple UI.
- **MongoDB Storage:** Persistent storage for all data.
- **Playwright Bot:** (Template included) For future automation of applications.

---

## Tech Stack

React • FastAPI (Python) • MongoDB • Playwright • OpenAI API • Docker

---

## Quick Start

1. **Set OpenAI Key:**\
   Edit `backend/.env` — put your key as `OPENAI_API_KEY=sk-...`

2. **Run Everything:**\
   Start Docker Desktop. In your project folder:

   ```bash
   docker-compose up --build
   ```

3. **Access App:**

   - Frontend: [http://localhost:3000](http://localhost:3000)
   - API docs: [http://localhost:8000/docs](http://localhost:8000/docs)

---

## API Endpoints

| Endpoint        | Method | Description                |
| --------------- | ------ | -------------------------- |
| /register       | POST   | Register new user          |
| /login          | POST   | User login                 |
| /preferences    | POST   | Save job preferences       |
| /applications   | POST   | Log a job application      |
| /applications   | GET    | Get application log        |
| /tailor\_resume | POST   | AI-tailor resume for a job |

---

## FAQ

- **OpenAI quota error?**\
  Check your [usage and billing](https://platform.openai.com/account/usage).
- **Want true auto-applying?**\
  Use `/bot/apply_bot.py` as a starting template for Playwright automations.

---

## License

MIT — PRs welcome!\
*Built by Danilo Chaves. Powered by FastAPI, React, MongoDB, OpenAI.*

