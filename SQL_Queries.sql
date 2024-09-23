/*Users*/
CREATE TABLE users(
	id SERIAL PRIMARY KEY,
	username VARCHAR(255) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


/*Photos*/
CREATE TABLE photos(
	id SERIAL PRIMARY KEY,
	image_url VARCHAR(355) NOT NULL,
	user_id INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY(user_id) REFERENCES users(id)
);


/*Comments*/
CREATE TABLE comments(
	id SERIAL PRIMARY KEY,
	comment_text VARCHAR(255) NOT NULL,
	user_id INTEGER NOT NULL,
	photo_id INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY(user_id) REFERENCES users(id),
	FOREIGN KEY(photo_id) REFERENCES photos(id)
);


/*Likes*/
CREATE TABLE likes(
	user_id INTEGER NOT NULL,
	photo_id INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY(user_id, photo_id),
	FOREIGN KEY(user_id) REFERENCES users(id),
	FOREIGN KEY(photo_id) REFERENCES photos(id)
);


/*follows*/
CREATE TABLE follows(
	follower_id INTEGER NOT NULL,
	followee_id INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY(follower_id, followee_id),
	FOREIGN KEY (follower_id) REFERENCES users(id),
	FOREIGN KEY (followee_id) REFERENCES users(id)
);


/*Tags*/
CREATE TABLE tags(
	id SERIAL PRIMARY KEY,
	tag_name VARCHAR(255) UNIQUE NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


/*Photos - Tags*/
CREATE TABLE photo_tags(
	photo_id INTEGER NOT NULL,
	tag_id INTEGER NOT NULL,
	PRIMARY KEY(photo_id, tag_id),
	FOREIGN KEY(photo_id) REFERENCES photos(id),
	FOREIGN KEY(tag_id) REFERENCES tags(id)
);


-- MARKETING ANALYSIS
--  1. Loyal User Reward: The marketing team wants to reward the most loyal users, i.e., those who have been using the platform for the longest time.
-- Task: Identify the five oldest users on Instagram from the provided database.
SELECT * FROM users
ORDER BY created_at
LIMIT 5;


--  2. Inactive User Engagement: The team wants to encourage inactive users to start posting by sending them promotional emails.
-- Task: Identify users who have never posted a single photo on Instagram.
SELECT DISTINCT user_id
FROM photos;		-- 74 users have posted photos on insta
------------------------------------------------------------
SELECT id, username 
FROM users
WHERE id NOT IN (SELECT DISTINCT user_id
FROM photos);
-- OR
SELECT u.id, u.username 
FROM users u
LEFT JOIN photos p
ON u.id = p.user_id
WHERE p.id IS NULL;


-- 3. Contest Winner Declaration: The team has organized a contest where the user with the most likes on a single photo wins.
-- Task: Determine the winner of the contest and provide their details to the team.
SELECT u.id AS user_id, u.username, l.photo_id, p.image_url, COUNT(l.*) AS total_likes
	FROM likes l
	LEFT JOIN photos p
	ON p.id = l.photo_id
	LEFT JOIN users u
	ON u.id = p.user_id
	GROUP BY l.photo_id, p.image_url, u.id
	ORDER BY total_likes DESC
LIMIT 1;


--  4. Hashtag Research: A partner brand wants to know the most popular hashtags to use in their posts to reach the most people.
-- Task: Identify and suggest the top five most commonly used hashtags on the platform.
SELECT p.tag_id, t.tag_name, COUNT(*) AS total
FROM photo_tags p
LEFT JOIN tags t
ON p.tag_id = t.id
GROUP BY p.tag_id, t.tag_name
ORDER BY total DESC, p.tag_id
LIMIT 5;


--  5. Ad Campaign Launch: The team wants to know the best day of the week to launch ads.
-- Task: Determine the day of the week when most users register on Instagram. Provide insights on when to schedule an ad campaign.
SELECT TO_CHAR(created_at, 'Day') AS day_of_week, COUNT(*) AS total
FROM users
GROUP BY day_of_week
ORDER BY total DESC
LIMIT 2;


-- INVESTOR METRICS
--  1. User Engagement: Investors want to know if users are still active and posting on Instagram or if they are making fewer posts.
-- Task: Calculate the average number of posts per user on Instagram. Also, provide the total number of photos on Instagram divided by the total number of users.
SELECT
 (SELECT COUNT(*) FROM photos) / (SELECT COUNT(DISTINCT user_id) FROM photos) AS avg_posts_per_user ;

SELECT
 (SELECT COUNT(*) FROM photos) / (SELECT COUNT(*) FROM users) AS avg_posts;


-- 2. Bots & Fake Accounts: Investors want to know if the platform is crowded with fake and dummy accounts.
-- Task: Identify users (potential bots) who have liked every single photo on the site, as this is not typically possible for a normal user.
SELECT l.user_id, u.username
FROM users u
JOIN likes l
ON u.id = l.user_id
GROUP BY l.user_id, u.username
HAVING COUNT(DISTINCT l.photo_id) = (SELECT COUNT(*) FROM photos)
ORDER BY l.user_id;







