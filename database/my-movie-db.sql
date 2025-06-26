create database MovieRatingSystem

/* 创建电影表 */
DROP TABLE IF EXISTS `movies`;
CREATE TABLE `movies` (
  `MovieID` int NOT NULL AUTO_INCREMENT,
  `Title` varchar(255) NOT NULL,
  `ReleaseYear` int DEFAULT NULL,
  `Duration` int DEFAULT NULL,
  `Genre` varchar(50) DEFAULT NULL,
  `语言` varchar(50) DEFAULT NULL,
  `Country` varchar(50) DEFAULT NULL,
  `Synopsis` text,
  `Rating` decimal(3,1) DEFAULT '0.0',
  `cover_url` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`MovieID`)
)

/* 创建导演表 */
DROP TABLE IF EXISTS `directors`;
CREATE TABLE `directors` (
  `DirectorID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) NOT NULL,
  `Gender` enum('男','女','未知') DEFAULT '未知',
  `BirthDate` date DEFAULT NULL,
  `Nationality` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`DirectorID`)
)

/* 创建电影-导演表 */
DROP TABLE IF EXISTS `moviedirectors`;
CREATE TABLE `moviedirectors` (
  `MovieID` int NOT NULL,
  `DirectorID` int NOT NULL,
  PRIMARY KEY (`MovieID`,`DirectorID`),
  KEY `DirectorID` (`DirectorID`),
  KEY `idx_md_movieid` (`MovieID`),
  KEY `idx_md_directorid` (`DirectorID`),
  CONSTRAINT `moviedirectors_ibfk_1` FOREIGN KEY (`MovieID`) REFERENCES `movies` (`MovieID`) ON DELETE CASCADE,
  CONSTRAINT `moviedirectors_ibfk_2` FOREIGN KEY (`DirectorID`) REFERENCES `directors` (`DirectorID`) ON DELETE CASCADE
)

/* 创建演员表 */
DROP TABLE IF EXISTS `actors`;
CREATE TABLE `actors` (
  `ActorID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) NOT NULL,
  `Gender` enum('男','女','未知') DEFAULT '未知',
  `BirthDate` date DEFAULT NULL,
  `Nationality` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`ActorID`)
)

/* 创建电影-演员表 */
DROP TABLE IF EXISTS `movieactors`;
CREATE TABLE `movieactors` (
  `MovieID` int NOT NULL,
  `ActorID` int NOT NULL,
  PRIMARY KEY (`MovieID`,`ActorID`),
  KEY `ActorID` (`ActorID`),
  KEY `idx_ma_movieid` (`MovieID`),
  KEY `idx_ma_actorid` (`ActorID`),
  CONSTRAINT `movieactors_ibfk_1` FOREIGN KEY (`MovieID`) REFERENCES `movies` (`MovieID`) ON DELETE CASCADE,
  CONSTRAINT `movieactors_ibfk_2` FOREIGN KEY (`ActorID`) REFERENCES `actors` (`ActorID`) ON DELETE CASCADE
)

/* 创建影评表 */
DROP TABLE IF EXISTS `reviews`;
CREATE TABLE `reviews` (
  `ReviewID` int NOT NULL AUTO_INCREMENT,
  `UserID` int DEFAULT NULL,
  `MovieID` int DEFAULT NULL,
  `Comment` text,
  `Rating` decimal(3,1) DEFAULT NULL,
  `ReviewDate` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ReviewID`),
  KEY `UserID` (`UserID`),
  KEY `MovieID` (`MovieID`),
  KEY `idx_reviews_movieid` (`MovieID`),
  KEY `idx_reviews_userid` (`UserID`),
  CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`) ON DELETE CASCADE,
  CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`MovieID`) REFERENCES `movies` (`MovieID`) ON DELETE CASCADE,
  CONSTRAINT `reviews_chk_1` CHECK (((`Rating` >= 0) and (`Rating` <= 10)))
)

/* 创建用户表 */
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `UserID` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(100) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `RegistrationDate` datetime DEFAULT CURRENT_TIMESTAMP,
  `Role` enum('user','admin') NOT NULL DEFAULT 'user',
  `avatar_url` varchar(512) DEFAULT NULL,
  PRIMARY KEY (`UserID`),
  UNIQUE KEY `Username` (`username`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `Email` (`email`)
)

/* 电影详情 */
create view v_movie_details as
select   m.movieID,m.title,m.releaseYear,m.duration,m.genre,m.language,m.country,m.synopsis,m.cover_url,m.rating,
    (
        select group_concat(d.name separator ' / ')
        from moviedirectors md
        join directors d on md.directorID = d.directorID
        where md.movieID = m.movieID
    ) as director_name,
    (
        select group_concat(a.name separator ' / ')
        from movieactors ma
        join actors a on ma.ActorID = a.ActorID
        where ma.movieID = m.movieID
    ) as actors_list
from movies m

/* 热门电影 */
create view hot_movies_view as
select
    movieID,title,releaseYear,cover_url,rating,director_name,actors_list
from v_movie_details
order by
    releaseYear desc,
    rating desc
limit 5;

/* 用户自己的所有影评 */
create view v_user_reviews as
SELECT
    r.ReviewID,
    r.UserID,
    r.MovieID,
    r.Comment,
    r.Rating,
    r.ReviewDate,
    m.title AS movie_title, 
    m.cover_Url AS movie_cover_url 
FROM
    reviews r
JOIN
    movies m ON r.MovieID = m.movieID;

/* 管理员的管理所有影评 */
CREATE VIEW v_all_review_details AS
SELECT
    r.ReviewID,
    r.UserID,
    r.MovieID,
    r.Comment,
    r.Rating,
    r.ReviewDate,
    u.username,           
    m.title AS movie_title  
FROM
    reviews r
JOIN
    users u ON r.UserID = u.userID
JOIN
    movies m ON r.MovieID = m.movieID;

/* 电影的所有影评 */
CREATE VIEW v_review_details AS
SELECT
    r.ReviewID,
    r.MovieID,
    r.UserID,
    r.Comment,
    r.Rating,
    r.ReviewDate,
    u.username,
    u.avatar_url AS user_avatar_url 
FROM
    reviews r
JOIN
    users u ON r.UserID = u.userID; 

/* 通过演员的id查询其出演的所有电影 */
DELIMITER &&
CREATE PROCEDURE get_movies_by_actor_id(IN p_actor_id INT)
BEGIN
    SELECT * FROM v_movie_details 
    WHERE movieID IN (
        SELECT movieID FROM movieactors WHERE actorID = p_actor_id
    );
END;

/* 通过导演的id查询其导演的所有电影 */
DELIMITER &&
CREATE PROCEDURE get_movies_by_director_id(IN p_director_id INT)
BEGIN
    SELECT * FROM v_movie_details 
    WHERE movieID IN (
        SELECT movieID FROM moviedirectors WHERE directorID = p_director_id
    );
END;

/* 新增评论后的触发器 */
DELIMITER &&
CREATE TRIGGER update_movie_rating_after_insert
AFTER INSERT ON reviews
FOR EACH ROW
BEGIN
    UPDATE movies m
    SET m.rating = (SELECT AVG(r.Rating) FROM reviews r WHERE r.MovieID = NEW.MovieID)
    WHERE m.movieID = NEW.MovieID;
END ;

/* 更新评论后的触发器 */
DELIMITER &&
CREATE TRIGGER update_movie_rating_after_update
AFTER UPDATE ON reviews
FOR EACH ROW
BEGIN
    UPDATE movies m
    SET m.rating = (SELECT AVG(r.Rating) FROM reviews r WHERE r.MovieID = NEW.MovieID)
    WHERE m.movieID = NEW.MovieID;
END ;

/* 删除评论后的触发器 */
DELIMITER &&
CREATE TRIGGER update_movie_rating_after_delete
AFTER DELETE ON reviews
FOR EACH ROW
BEGIN
    UPDATE movies m
    SET m.rating = COALESCE((SELECT AVG(r.Rating) FROM reviews r WHERE r.MovieID = OLD.MovieID), 0)
    WHERE m.movieID = OLD.MovieID;
END ;

/* 1. 为 reviews 表的两个外键添加索引 */
CREATE INDEX idx_reviews_movieid ON reviews (MovieID);
CREATE INDEX idx_reviews_userid ON reviews (UserID);

/* 2. 为 moviedirectors 连接表的两个外键添加索引 */
CREATE INDEX idx_md_movieid ON moviedirectors (movieID);
CREATE INDEX idx_md_directorid ON moviedirectors (directorID);

/* 3. 为 movieactors 连接表的两个外键添加索引 */
CREATE INDEX idx_ma_movieid ON movieactors (movieID);
CREATE INDEX idx_ma_actorid ON movieactors (ActorID);
