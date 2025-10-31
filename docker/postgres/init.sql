-- PostgreSQL Initialization Script for ASIL Lakehouse POC
-- This script creates databases and loads schemas

-- ============================================
-- CREATE DATABASES
-- ============================================

-- Instagram-like social media database (main POC database)  
-- Note: socialnet database is created automatically by Docker Compose env vars
CREATE DATABASE instagram_db;

-- ============================================
-- CONNECT TO INSTAGRAM DATABASE AND CREATE SCHEMA
-- ============================================

\c instagram_db;

-- Load Instagram schema
\i /docker-entrypoint-initdb.d/instagram_schema.sql;

-- ============================================
-- CREATE SAMPLE DATA (Optional - for quick testing)
-- ============================================

-- Insert a few sample users for testing
INSERT INTO users (username, full_name, bio, email, follower_count, following_count, is_verified, location) VALUES
('john_doe', 'John Doe', 'Travel enthusiast 🌍 | Photography lover 📸', 'john@example.com', 1250, 450, false, 'New York, USA'),
('jane_smith', 'Jane Smith', 'Food blogger | Recipe creator 🍳', 'jane@example.com', 5420, 320, true, 'Los Angeles, USA'),
('mike_wilson', 'Mike Wilson', 'Fitness coach | Healthy lifestyle 💪', 'mike@example.com', 3100, 890, false, 'Miami, USA'),
('sarah_jones', 'Sarah Jones', 'Fashion & Style | Designer ✨', 'sarah@example.com', 8900, 210, true, 'Paris, France'),
('alex_brown', 'Alex Brown', 'Tech enthusiast | Developer 💻', 'alex@example.com', 2300, 670, false, 'San Francisco, USA')
ON CONFLICT (username) DO NOTHING;

-- Insert sample posts
INSERT INTO posts (user_id, caption, like_count, comment_count, view_count, location, created_at) VALUES
(1, 'Amazing sunset at the beach! 🌅 #sunset #beach #travel', 245, 18, 1200, 'Malibu Beach', NOW() - INTERVAL '2 days'),
(2, 'New recipe alert! Homemade pasta 🍝 #cooking #foodie #italian', 532, 45, 2100, 'Home Kitchen', NOW() - INTERVAL '1 day'),
(3, 'Morning workout complete! 💪 #fitness #motivation #health', 189, 12, 890, 'Gold''s Gym', NOW() - INTERVAL '3 hours'),
(4, 'Spring collection preview ✨ #fashion #style #designer', 1203, 87, 5400, 'Paris Fashion Week', NOW() - INTERVAL '5 days'),
(5, 'Just deployed my new app! 🚀 #coding #developer #tech', 421, 34, 1800, 'Home Office', NOW() - INTERVAL '12 hours')
ON CONFLICT DO NOTHING;

-- Insert sample tags
INSERT INTO tags (name, usage_count) VALUES
('travel', 150),
('sunset', 89),
('beach', 120),
('cooking', 200),
('foodie', 180),
('italian', 95),
('fitness', 250),
('motivation', 300),
('health', 220),
('fashion', 400),
('style', 350),
('designer', 180),
('coding', 160),
('developer', 140),
('tech', 190)
ON CONFLICT (name) DO NOTHING;

-- Link posts to tags
INSERT INTO post_tags (post_id, tag_id) VALUES
(1, 1), (1, 2), (1, 3),  -- Post 1: travel, sunset, beach
(2, 4), (2, 5), (2, 6),  -- Post 2: cooking, foodie, italian
(3, 7), (3, 8), (3, 9),  -- Post 3: fitness, motivation, health
(4, 10), (4, 11), (4, 12), -- Post 4: fashion, style, designer
(5, 13), (5, 14), (5, 15)  -- Post 5: coding, developer, tech
ON CONFLICT DO NOTHING;

-- Insert sample comments
INSERT INTO comments (post_id, user_id, text, like_count, created_at) VALUES
(1, 2, 'Wow! This is absolutely stunning! 😍', 12, NOW() - INTERVAL '1 day'),
(1, 3, 'Where is this? I need to visit!', 8, NOW() - INTERVAL '1 day'),
(2, 1, 'This looks delicious! Can you share the recipe?', 15, NOW() - INTERVAL '20 hours'),
(2, 4, 'I tried this yesterday, amazing! 🍝', 9, NOW() - INTERVAL '18 hours'),
(3, 5, 'Great job! Keep it up! 💪', 6, NOW() - INTERVAL '2 hours'),
(4, 1, 'Love the colors! When will it be available?', 23, NOW() - INTERVAL '4 days'),
(4, 2, 'This is gorgeous! 😍', 18, NOW() - INTERVAL '4 days'),
(5, 3, 'Congrats on the launch! 🎉', 11, NOW() - INTERVAL '10 hours')
ON CONFLICT DO NOTHING;

-- Insert sample likes
INSERT INTO likes (post_id, user_id, created_at) VALUES
(1, 2, NOW() - INTERVAL '1 day'),
(1, 3, NOW() - INTERVAL '1 day'),
(1, 4, NOW() - INTERVAL '1 day'),
(2, 1, NOW() - INTERVAL '20 hours'),
(2, 3, NOW() - INTERVAL '19 hours'),
(2, 5, NOW() - INTERVAL '18 hours'),
(3, 1, NOW() - INTERVAL '2 hours'),
(3, 2, NOW() - INTERVAL '2 hours'),
(4, 1, NOW() - INTERVAL '4 days'),
(4, 2, NOW() - INTERVAL '4 days'),
(4, 3, NOW() - INTERVAL '4 days'),
(5, 1, NOW() - INTERVAL '10 hours'),
(5, 2, NOW() - INTERVAL '10 hours'),
(5, 4, NOW() - INTERVAL '9 hours')
ON CONFLICT DO NOTHING;

-- Insert sample follows
INSERT INTO follows (follower_id, followed_id, created_at) VALUES
(1, 2, NOW() - INTERVAL '30 days'),
(1, 4, NOW() - INTERVAL '25 days'),
(2, 1, NOW() - INTERVAL '28 days'),
(2, 3, NOW() - INTERVAL '20 days'),
(3, 1, NOW() - INTERVAL '15 days'),
(3, 5, NOW() - INTERVAL '10 days'),
(4, 2, NOW() - INTERVAL '35 days'),
(5, 1, NOW() - INTERVAL '12 days'),
(5, 3, NOW() - INTERVAL '8 days')
ON CONFLICT DO NOTHING;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Show summary of created data
DO $$
BEGIN
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'Instagram Database Initialization Complete!';
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'Users created: %', (SELECT COUNT(*) FROM users);
    RAISE NOTICE 'Posts created: %', (SELECT COUNT(*) FROM posts);
    RAISE NOTICE 'Comments created: %', (SELECT COUNT(*) FROM comments);
    RAISE NOTICE 'Tags created: %', (SELECT COUNT(*) FROM tags);
    RAISE NOTICE 'Likes created: %', (SELECT COUNT(*) FROM likes);
    RAISE NOTICE 'Follows created: %', (SELECT COUNT(*) FROM follows);
    RAISE NOTICE '==============================================';
END $$;
