# Hacker News COBOL API
> Built with the [Hacker News dataset](https://www.kaggle.com/datasets/santiagobasulto/all-hacker-news-posts-stories-askshow-hn-polls).
Powered by COBOL in z/OS mainframe.

This project explores mainframe modernization by exposing 
VSAM data through a REST API, bridging COBOL batch 
processing with modern web development using the Zowe SDK.

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
4. Run IDCAMS JCL to create the VSAM cluster
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
│                            NODE.JS                            │
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
1. Part I - [link](https://medium.com/@pedrohenrique.oliveira119/lets-write-an-api-with-javascript-and-cobol-pt-i-f63c7c7b165b)
2. Part II - [link](https://medium.com/@pedrohenrique.oliveira119/lets-write-an-api-with-javascript-and-cobol-pt-ii-b11cf957d0f7)
3. Part III - [link]()

## License
This code was written with MIT License, see [LICENSE](LICENSE) for more details
