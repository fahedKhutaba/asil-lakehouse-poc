-- Instagram-like Social Media Database Schema
-- Complete schema for ASIL Lakehouse POC
-- Includes: Users, Posts, Comments, Tags, Likes, Follows, Media Metadata

-- ============================================
-- USERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(150),
    bio TEXT,
    profile_image_url VARCHAR(500),
    follower_count INTEGER DEFAULT 0,
    following_count INTEGER DEFAULT 0,
    post_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_verified BOOLEAN DEFAULT FALSE,
    email VARCHAR(150) UNIQUE,
    location VARCHAR(200)
);

-- ============================================
-- POSTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS posts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    caption TEXT,
    image_url VARCHAR(500),
    image_path VARCHAR(500),
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    location VARCHAR(200),
    is_video BOOLEAN DEFAULT FALSE,
    video_duration_seconds INTEGER,
    aspect_ratio VARCHAR(20)
);

-- ============================================
-- COMMENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS comments (
    id SERIAL PRIMARY KEY,
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    parent_comment_id INTEGER REFERENCES comments(id) ON DELETE CASCADE,
    text TEXT NOT NULL,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TAGS/HASHTAGS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS tags (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    usage_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- POST_TAGS JUNCTION TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS post_tags (
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    tag_id INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (post_id, tag_id)
);

-- ============================================
-- LIKES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS likes (
    id SERIAL PRIMARY KEY,
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(post_id, user_id)
);

-- ============================================
-- COMMENT_LIKES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS comment_likes (
    id SERIAL PRIMARY KEY,
    comment_id INTEGER NOT NULL REFERENCES comments(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(comment_id, user_id)
);

-- ============================================
-- FOLLOWS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS follows (
    follower_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    followed_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (follower_id, followed_id),
    CHECK (follower_id != followed_id)
);

-- ============================================
-- MEDIA_METADATA TABLE (for MinIO integration)
-- ============================================
CREATE TABLE IF NOT EXISTS media_metadata (
    id SERIAL PRIMARY KEY,
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    file_name VARCHAR(200) NOT NULL,
    file_size_bytes BIGINT,
    mime_type VARCHAR(50),
    width INTEGER,
    height INTEGER,
    minio_bucket VARCHAR(100) DEFAULT 'instagram-media',
    minio_key VARCHAR(500),
    thumbnail_url VARCHAR(500),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ai_description TEXT,
    ai_tags TEXT[]
);

-- ============================================
-- PERFORMANCE INDEXES
-- ============================================

-- Posts indexes
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_like_count ON posts(like_count DESC);

-- Comments indexes
CREATE INDEX IF NOT EXISTS idx_comments_post_id ON comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_user_id ON comments(user_id);
CREATE INDEX IF NOT EXISTS idx_comments_created_at ON comments(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_comments_parent ON comments(parent_comment_id);

-- Likes indexes
CREATE INDEX IF NOT EXISTS idx_likes_post_id ON likes(post_id);
CREATE INDEX IF NOT EXISTS idx_likes_user_id ON likes(user_id);
CREATE INDEX IF NOT EXISTS idx_likes_created_at ON likes(created_at DESC);

-- Tags indexes
CREATE INDEX IF NOT EXISTS idx_tags_name ON tags(name);
CREATE INDEX IF NOT EXISTS idx_tags_usage_count ON tags(usage_count DESC);

-- Post_tags indexes
CREATE INDEX IF NOT EXISTS idx_post_tags_post_id ON post_tags(post_id);
CREATE INDEX IF NOT EXISTS idx_post_tags_tag_id ON post_tags(tag_id);

-- Follows indexes
CREATE INDEX IF NOT EXISTS idx_follows_follower ON follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_follows_followed ON follows(followed_id);

-- Media metadata indexes
CREATE INDEX IF NOT EXISTS idx_media_post_id ON media_metadata(post_id);
CREATE INDEX IF NOT EXISTS idx_media_minio_key ON media_metadata(minio_key);

-- ============================================
-- USEFUL VIEWS FOR ANALYTICS
-- ============================================

-- View: User engagement statistics
CREATE OR REPLACE VIEW user_engagement_stats AS
SELECT 
    u.id,
    u.username,
    u.follower_count,
    u.following_count,
    u.post_count,
    COUNT(DISTINCT p.id) as actual_post_count,
    COALESCE(SUM(p.like_count), 0) as total_likes_received,
    COALESCE(SUM(p.comment_count), 0) as total_comments_received,
    COALESCE(AVG(p.like_count), 0) as avg_likes_per_post,
    COUNT(DISTINCT l.id) as total_likes_given,
    COUNT(DISTINCT c.id) as total_comments_made
FROM users u
LEFT JOIN posts p ON u.id = p.user_id
LEFT JOIN likes l ON u.id = l.user_id
LEFT JOIN comments c ON u.id = c.user_id
GROUP BY u.id, u.username, u.follower_count, u.following_count, u.post_count;

-- View: Popular posts
CREATE OR REPLACE VIEW popular_posts AS
SELECT 
    p.id,
    p.caption,
    p.like_count,
    p.comment_count,
    p.view_count,
    p.created_at,
    u.username as author_username,
    u.full_name as author_name,
    (p.like_count + p.comment_count * 2) as engagement_score
FROM posts p
JOIN users u ON p.user_id = u.id
ORDER BY engagement_score DESC;

-- View: Trending hashtags
CREATE OR REPLACE VIEW trending_hashtags AS
SELECT 
    t.id,
    t.name,
    t.usage_count,
    COUNT(DISTINCT pt.post_id) as actual_usage_count,
    COUNT(DISTINCT p.user_id) as unique_users,
    SUM(p.like_count) as total_likes,
    AVG(p.like_count) as avg_likes_per_post
FROM tags t
LEFT JOIN post_tags pt ON t.id = pt.tag_id
LEFT JOIN posts p ON pt.post_id = p.id
GROUP BY t.id, t.name, t.usage_count
ORDER BY actual_usage_count DESC;

-- ============================================
-- SAMPLE DATA QUERIES (for testing)
-- ============================================

-- These comments show example queries that can be used to test the schema

/*
-- Get user's feed (posts from followed users)
SELECT p.*, u.username, u.profile_image_url
FROM posts p
JOIN users u ON p.user_id = u.id
WHERE p.user_id IN (
    SELECT followed_id FROM follows WHERE follower_id = ?
)
ORDER BY p.created_at DESC
LIMIT 20;

-- Get post with all details
SELECT 
    p.*,
    u.username,
    u.profile_image_url,
    u.is_verified,
    COUNT(DISTINCT l.id) as like_count,
    COUNT(DISTINCT c.id) as comment_count
FROM posts p
JOIN users u ON p.user_id = u.id
LEFT JOIN likes l ON p.id = l.post_id
LEFT JOIN comments c ON p.id = c.post_id
WHERE p.id = ?
GROUP BY p.id, u.username, u.profile_image_url, u.is_verified;

-- Get comments for a post
SELECT 
    c.*,
    u.username,
    u.profile_image_url,
    u.is_verified
FROM comments c
JOIN users u ON c.user_id = u.id
WHERE c.post_id = ?
ORDER BY c.created_at ASC;

-- Search posts by hashtag
SELECT p.*, u.username
FROM posts p
JOIN users u ON p.user_id = u.id
JOIN post_tags pt ON p.id = pt.post_id
JOIN tags t ON pt.tag_id = t.id
WHERE t.name = ?
ORDER BY p.created_at DESC;

-- Get user profile with stats
SELECT 
    u.*,
    COUNT(DISTINCT p.id) as post_count,
    COUNT(DISTINCT f1.follower_id) as follower_count,
    COUNT(DISTINCT f2.followed_id) as following_count
FROM users u
LEFT JOIN posts p ON u.id = p.user_id
LEFT JOIN follows f1 ON u.id = f1.followed_id
LEFT JOIN follows f2 ON u.id = f2.follower_id
WHERE u.id = ?
GROUP BY u.id;
*/
