#!/usr/bin/env python3
"""
Quick Instagram Data Loader
Loads Instagram dataset into PostgreSQL database
"""

import csv
import psycopg2
import random
from datetime import datetime, timedelta
from faker import Faker

# Database connection
DB_CONFIG = {
    'host': 'localhost',
    'port': 5433,
    'database': 'instagram_db',
    'user': 'lakeuser',
    'password': 'lakepass123'
}

fake = Faker()

def create_users(conn, num_users=15):
    """Create synthetic users"""
    print(f"Creating {num_users} users...")
    cursor = conn.cursor()
    users = []
    
    for i in range(num_users):
        username = fake.user_name() + str(random.randint(1, 999))
        full_name = fake.name()
        bio = fake.sentence(nb_words=10)
        email = fake.email()
        follower_count = random.randint(100, 10000)
        following_count = random.randint(50, 1000)
        is_verified = random.choice([True, False]) if i < 3 else False
        location = fake.city() + ", " + fake.country()
        
        try:
            cursor.execute("""
                INSERT INTO users (username, full_name, bio, email, follower_count, 
                                 following_count, is_verified, location)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING id
            """, (username, full_name, bio, email, follower_count, following_count, 
                  is_verified, location))
            user_id = cursor.fetchone()[0]
            users.append(user_id)
        except Exception as e:
            print(f"Error creating user: {e}")
            conn.rollback()
            continue
    
    conn.commit()
    print(f"✓ Created {len(users)} users")
    return users

def extract_hashtags(hashtag_string):
    """Extract hashtags from string"""
    if not hashtag_string or hashtag_string == '':
        return []
    # Split by various possible separators
    import re
    # Remove # symbols and split by common separators
    cleaned = hashtag_string.replace('#', '')
    # Split by space, comma, or special characters
    tags = re.split(r'[\s,;]+', cleaned)
    return [tag.strip() for tag in tags if tag and len(tag.strip()) > 0]

def load_posts(conn, csv_file, user_ids):
    """Load posts from CSV"""
    print(f"Loading posts from {csv_file}...")
    cursor = conn.cursor()
    
    post_count = 0
    tag_map = {}
    
    # Try different encodings
    encodings = ['utf-8', 'latin-1', 'iso-8859-1', 'cp1252']
    reader = None
    
    for encoding in encodings:
        try:
            with open(csv_file, 'r', encoding=encoding) as f:
                reader = list(csv.DictReader(f))
                print(f"✓ Successfully read CSV with {encoding} encoding")
                break
        except UnicodeDecodeError:
            continue
    
    if reader is None:
        raise Exception("Could not read CSV file with any encoding")
    
    for row in reader:
            # Assign random user
            user_id = random.choice(user_ids)
            
            # Extract data
            caption = row['Caption']
            like_count = int(row['Likes'])
            comment_count = int(row['Comments'])
            view_count = int(row['Impressions'])
            
            # Random date in last 90 days
            days_ago = random.randint(1, 90)
            created_at = datetime.now() - timedelta(days=days_ago)
            
            # Insert post
            try:
                cursor.execute("""
                    INSERT INTO posts (user_id, caption, like_count, comment_count, 
                                     view_count, created_at)
                    VALUES (%s, %s, %s, %s, %s, %s)
                    RETURNING id
                """, (user_id, caption, like_count, comment_count, view_count, created_at))
                
                post_id = cursor.fetchone()[0]
                post_count += 1
                
                # Extract and insert hashtags
                hashtags = extract_hashtags(row['Hashtags'])
                for tag_name in hashtags[:10]:  # Limit to 10 tags per post
                    if tag_name not in tag_map:
                        # Create tag
                        cursor.execute("""
                            INSERT INTO tags (name, usage_count)
                            VALUES (%s, 1)
                            ON CONFLICT (name) DO UPDATE SET usage_count = tags.usage_count + 1
                            RETURNING id
                        """, (tag_name,))
                        tag_id = cursor.fetchone()[0]
                        tag_map[tag_name] = tag_id
                    else:
                        tag_id = tag_map[tag_name]
                    
                    # Link post to tag
                    cursor.execute("""
                        INSERT INTO post_tags (post_id, tag_id)
                        VALUES (%s, %s)
                        ON CONFLICT DO NOTHING
                    """, (post_id, tag_id))
                
                # Create some likes
                num_likes = min(like_count, len(user_ids) * 2)  # Limit likes
                like_users = random.sample(user_ids * 2, min(num_likes, 20))  # Max 20 likes per post
                for like_user_id in like_users[:20]:
                    if like_user_id <= max(user_ids):  # Valid user
                        try:
                            cursor.execute("""
                                INSERT INTO likes (post_id, user_id, created_at)
                                VALUES (%s, %s, %s)
                                ON CONFLICT DO NOTHING
                            """, (post_id, like_user_id, created_at + timedelta(hours=random.randint(1, 24))))
                        except:
                            pass
                
                # Create some comments
                num_comments = min(comment_count, 5)  # Max 5 comments per post
                for _ in range(num_comments):
                    comment_user_id = random.choice(user_ids)
                    comment_text = fake.sentence(nb_words=random.randint(5, 15))
                    try:
                        cursor.execute("""
                            INSERT INTO comments (post_id, user_id, text, created_at)
                            VALUES (%s, %s, %s, %s)
                        """, (post_id, comment_user_id, comment_text, 
                              created_at + timedelta(hours=random.randint(1, 48))))
                    except:
                        pass
                
                if post_count % 10 == 0:
                    print(f"  Loaded {post_count} posts...")
                    conn.commit()
                    
            except Exception as e:
                print(f"Error loading post: {e}")
                conn.rollback()
                continue
    
    conn.commit()
    print(f"✓ Loaded {post_count} posts with {len(tag_map)} unique hashtags")
    return post_count

def create_follows(conn, user_ids):
    """Create follow relationships"""
    print("Creating follow relationships...")
    cursor = conn.cursor()
    
    follow_count = 0
    for user_id in user_ids:
        # Each user follows 3-8 random other users
        num_follows = random.randint(3, 8)
        follows = random.sample([u for u in user_ids if u != user_id], 
                               min(num_follows, len(user_ids) - 1))
        
        for followed_id in follows:
            try:
                cursor.execute("""
                    INSERT INTO follows (follower_id, followed_id)
                    VALUES (%s, %s)
                    ON CONFLICT DO NOTHING
                """, (user_id, followed_id))
                follow_count += 1
            except:
                pass
    
    conn.commit()
    print(f"✓ Created {follow_count} follow relationships")

def print_summary(conn):
    """Print database summary"""
    cursor = conn.cursor()
    
    print("\n" + "="*50)
    print("DATABASE SUMMARY")
    print("="*50)
    
    cursor.execute("SELECT COUNT(*) FROM users")
    print(f"Users: {cursor.fetchone()[0]}")
    
    cursor.execute("SELECT COUNT(*) FROM posts")
    print(f"Posts: {cursor.fetchone()[0]}")
    
    cursor.execute("SELECT COUNT(*) FROM comments")
    print(f"Comments: {cursor.fetchone()[0]}")
    
    cursor.execute("SELECT COUNT(*) FROM tags")
    print(f"Tags: {cursor.fetchone()[0]}")
    
    cursor.execute("SELECT COUNT(*) FROM likes")
    print(f"Likes: {cursor.fetchone()[0]}")
    
    cursor.execute("SELECT COUNT(*) FROM follows")
    print(f"Follows: {cursor.fetchone()[0]}")
    
    print("="*50 + "\n")

def main():
    print("\n🚀 Instagram Data Loader")
    print("="*50)
    
    # Connect to database
    print("Connecting to database...")
    conn = psycopg2.connect(**DB_CONFIG)
    print("✓ Connected\n")
    
    try:
        # Create users
        user_ids = create_users(conn, num_users=15)
        
        # Load posts from CSV
        csv_file = 'data/Instagram data.csv'
        load_posts(conn, csv_file, user_ids)
        
        # Create follows
        create_follows(conn, user_ids)
        
        # Print summary
        print_summary(conn)
        
        print("✅ Data loading complete!")
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        conn.rollback()
    finally:
        conn.close()

if __name__ == '__main__':
    main()
