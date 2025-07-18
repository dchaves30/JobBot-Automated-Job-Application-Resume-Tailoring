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
