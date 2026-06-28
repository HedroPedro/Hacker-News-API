# Hacker News COBOL API

A REST API that uses COBOL running on IBM z/OS to query 
aggregated Hacker News data stored in a VSAM dataset.

## Stack
- Node.js + Express - 
- Zowe SDK - Mainframe Integration
- COBOL + JCL - Manipulate Data
- VSAM KSDS - Storage

## Routes
- GET /api/hn/year/{year}
- GET /api/hn/month/{month}
- GET /api/hn/year/{year}/{month}

## Setup
1. Configure Zowe profile with z/OS credentials
2. Upload and compile GETHN.cbl
3. Load data via PARSECSV.cbl
4. npm install && npm run start

## Architecture

```
┌───────────────────────────────────────────────────────────────┐
│                             REST                              │
│                            CLIENT                             │
└────────────────────────────────┬──────────────────────────────┘
                               ▲ │ Request
                          JSON │ ▼
┌──────────────────────────────┴────────────────────────────────┐
│                             NODE JS.                          │
│                              API                              │
└────────────────────────────────┬──────────────────────────────┘
                               ▲ │ JCL with parameters
                          JSON │ ▼
┌──────────────────────────────┴────────────────────────────────┐
│                             Z/OS                              │
│                             COBOL                             │
│                              ▲ │ IDS                          │
│                         DATA │ ▼                              │                              
│┌─────────────────────────────┴───────────────────────────────┐│
││                            VSAM                             ││  
│└─────────────────────────────────────────────────────────────┘│
└───────────────────────────────────────────────────────────────┘
```

## Article Series
Part I - link
Part II - link
Part III - link