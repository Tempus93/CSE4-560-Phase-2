# GridironAnalytics: A Relational Approach to NFL Performance
**CSE 4/560 Data Models and Query Language | Spring 2026**

## Project Overview
GridironAnalytics is a PostgreSQL-based relational database system designed to centralize fragmented NFL team and player performance data into a single, queryable source of truth. The system specifically targets sports bettors, analysts, and scouts who are currently underserved by disorganized or paywalled data sources.

By quantifying the impact of external variables—such as weather conditions and player usage (snaps)—this project empowers users to move from anecdotal gambling to informed statistical wagering.

## The Team
* **Justin Downer** (jrdowner) - Team Leader 
* **Colin Xiao** (colinxia) 
* **Matt Jacovelli** (mkjacove) 

## Database Architecture
The schema consists of **11 relations** organized around a core hierarchy from Conference down to individual player statistics, with **Games** serving as the central transactional entity.

### Core Tables
1.  **Organizational**: `Conference`, `Division`, `Teams` 
2.  **Personnel**: `Player`, `Seasons` 
3.  **Transactional**: `Games`, `Weather` 
4.  **Performance**: `SnapCounts`, `PlayerStats`, `OffensiveStats`, `DefensiveStats`, `SpecialTeamStats` 

### Entity-Relationship Summary
* **One-to-Many**: Standard hierarchy (e.g., Division → Teams).
* **Transactional Links**: Games link to multiple PlayerStats and Weather observations.
* **Data Integrity**: Enforced via `ON DELETE CASCADE` and `RESTRICT` actions to preserve historical game data while maintaining clean player records.

## Phase 2 Implementation
This phase focuses on the technical execution of the database, involving over **3,000 records** and advanced SQL logic.

### Key Tasks
- [ ] **Data Loading**: Bulk import of production datasets using `load.sql`.
- [ ] **Normalization**: Verification of all relations to meet **Boyce-Codd Normal Form (BCNF)**.
- [ ] **Advanced Queries**: Implementation of 10+ complex SQL queries (Joins, Subqueries, Stored Procedures).
- [ ] **Transactions**: Failure handling using Triggers.
- [ ] **Performance Tuning**: Indexing strategies and `EXPLAIN` cost analysis.
