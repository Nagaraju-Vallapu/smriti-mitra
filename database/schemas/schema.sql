-- ============================================================
-- SMRITI MITRA
-- PostgreSQL Database Schema
-- ============================================================

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) UNIQUE,
    email VARCHAR(150) UNIQUE,
    password_hash TEXT NOT NULL,
    language VARCHAR(50) DEFAULT 'English',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- ELDERLY PROFILE
-- ============================================================

CREATE TABLE elderly_profile (
    profile_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL UNIQUE,
    age INTEGER CHECK (age >= 0 AND age <= 120),
    accessibility_mode VARCHAR(50) DEFAULT 'high_contrast',
    emergency_contact VARCHAR(20),
    preferred_language VARCHAR(50) DEFAULT 'English',

    CONSTRAINT fk_elderly_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);


-- ============================================================
-- CAREGIVER
-- ============================================================

CREATE TABLE caregiver (
    caregiver_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    relationship VARCHAR(50),

    CONSTRAINT fk_caregiver_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);


-- ============================================================
-- HEALTH WORKER
-- ============================================================

CREATE TABLE health_worker (
    worker_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    specialization VARCHAR(100),

    CONSTRAINT fk_health_worker_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);


-- ============================================================
-- COGNITIVE GAMES
-- ============================================================

CREATE TABLE cognitive_game (
    game_id SERIAL PRIMARY KEY,
    game_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    description TEXT,
    difficulty_level INTEGER NOT NULL DEFAULT 1,

    CONSTRAINT chk_game_difficulty
        CHECK (difficulty_level BETWEEN 1 AND 10)
);


-- ============================================================
-- GAME SESSION
-- ============================================================

CREATE TABLE game_session (
    session_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    game_id INTEGER NOT NULL,
    start_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    score NUMERIC(6,2),
    accuracy NUMERIC(5,2),
    reaction_time NUMERIC(10,2),

    CONSTRAINT fk_session_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_session_game
        FOREIGN KEY (game_id)
        REFERENCES cognitive_game(game_id)
        ON DELETE CASCADE,

    CONSTRAINT chk_accuracy
        CHECK (accuracy IS NULL OR (accuracy >= 0 AND accuracy <= 100)),

    CONSTRAINT chk_score
        CHECK (score IS NULL OR score >= 0),

    CONSTRAINT chk_reaction_time
        CHECK (reaction_time IS NULL OR reaction_time >= 0)
);


-- ============================================================
-- PERFORMANCE RECORD
-- ============================================================

CREATE TABLE performance_record (
    record_id SERIAL PRIMARY KEY,
    session_id INTEGER NOT NULL,
    score NUMERIC(6,2),
    accuracy NUMERIC(5,2),
    reaction_time NUMERIC(10,2),
    difficulty INTEGER,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_performance_session
        FOREIGN KEY (session_id)
        REFERENCES game_session(session_id)
        ON DELETE CASCADE,

    CONSTRAINT chk_performance_accuracy
        CHECK (accuracy IS NULL OR (accuracy >= 0 AND accuracy <= 100)),

    CONSTRAINT chk_performance_difficulty
        CHECK (difficulty IS NULL OR difficulty BETWEEN 1 AND 10)
);


-- ============================================================
-- REMINDERS
-- ============================================================

CREATE TABLE reminder (
    reminder_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    reminder_type VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    scheduled_time TIMESTAMP NOT NULL,
    completed BOOLEAN DEFAULT FALSE,

    CONSTRAINT fk_reminder_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);


-- ============================================================
-- SYNC RECORD
-- ============================================================

CREATE TABLE sync_record (
    sync_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    sync_status VARCHAR(30) NOT NULL DEFAULT 'pending',
    synced_at TIMESTAMP,

    CONSTRAINT fk_sync_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_game_session_user
    ON game_session(user_id);

CREATE INDEX idx_game_session_game
    ON game_session(game_id);

CREATE INDEX idx_performance_session
    ON performance_record(session_id);

CREATE INDEX idx_reminder_user
    ON reminder(user_id);

CREATE INDEX idx_sync_user
    ON sync_record(user_id);