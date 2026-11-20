# AI-SUPPLY-CHAIN-EVENT-INTELLIGENCE-DISRUPTION-PROPAGATION-ENGINE
A Data Science project built during the Athenura Data Analytics & Data Science internship.
## About the Project
  When an event hits one part of a supply network (a port closure, a supplier outage, a flood), what else is likely to be affected, how quickly, and through which dependencies?This platform answers that question. It reads external events, links them to a multi-tier supply-chain graph, estimates how the disruption spreads, and shows the evidence behind every result.
**Domain (MVP):** Consumer Electronics (mobile / laptop) manufacturing supply chain
## How It Works
Internal Data + External Events → Event Detection (NLP) → Entity Resolution → Supply-Chain Graph → Disruption Propagation → Impact Estimation → Scenario Analysis → Decision Support
## Team

<img width="1096" height="293" alt="image" src="https://github.com/user-attachments/assets/3fc40689-15f5-450e-a172-75b109f451d7" />


## Folder Structure

| Folder | Purpose | Owner |
|---|---|---|
| `backend/` | FastAPI services and database code | Atharv |
| `frontend/` | React dashboard | Atharv |
| `data/` | Datasets (CSV), data cleaning | Prince |
| `nlp/` | Event extraction and NLP | Prince, Shivani |
| `graph/` | Entity resolution, Neo4j scripts | Vandana |
| `propagation/` | Propagation engine, scenarios | Shivani |
| `docs/` | PRD, data dictionary, schema, reports | All |

## Tech Stack

Python, Pandas, spaCy, sentence-transformers, Neo4j, PostgreSQL, FastAPI, React, Plotly, Scikit-learn, XGBoost, MLflow, Celery + Redis, Docker

## Timeline

19 Nov 2026 to 15 Jan 2027 (10 phases). Every Sunday is kept for completing pending work.

## Git Workflow

- Do not push directly to `main`.
- Work on your own branch (`atharv`, `prince`, `vandana`, `shivani`).
- Pull before you start working, commit with a short clear message, then push.
- Open a pull request to merge into `main`.

## Setup

Setup instructions will be added after the backend and database are ready.

## Project Boundary

This is an intelligence and decision-support system. It does not place orders, reroute shipments or make procurement decisions automatically.
