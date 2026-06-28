# Hacker News COBOL API

A REST API that uses COBOL running on IBM z/OS to query 
aggregated Hacker News data stored in a VSAM dataset.

## Stack
- Node.js + Express - API layer and route handling
- Zowe SDK - Mainframe Integration and job submission
- COBOL + JCL - Manipulate Data
- VSAM KSDS - Indexed data storage on z/OS

## Routes
- GET /api/hn/year/{year}
- GET /api/hn/month/{month}
- GET /api/hn/year/{year}/{month}

## Setup
1. Configure Zowe profile with z/OS credentials
2. Upload and compile PARSECSV and GETHN.cbl
3. Run IDCAMS JCL to create the VSAM cluster
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
│                            NODE. JS                           │
│                              API                              │
└────────────────────────────────┬──────────────────────────────┘
                               ▲ │ JCL with parameters
                          JSON │ ▼
┌──────────────────────────────┴────────────────────────────────┐
│                             Z/OS                              │
│                             COBOL                             │
│                              ▲ │ DATA REQUEST                 │
│                         DATA │ ▼                              │
│┌─────────────────────────────┴───────────────────────────────┐│
││                            VSAM                             ││
│└─────────────────────────────────────────────────────────────┘│
└───────────────────────────────────────────────────────────────┘
```

## Article Series
1. Part I - link
2. Part II - link
3. Part III - link