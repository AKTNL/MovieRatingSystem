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

INSERT INTO `movies` VALUES (1,'肖申克的救赎',1994,142,'剧情','英语','美国','一名银行家被冤入狱，最终通过智慧重获自由。',7.5,'https://raw.githubusercontent.com/AKTNL/images/refs/heads/main/covers/shawshank.jpg'),(2,'霸王别姬',1993,171,'爱情/历史','汉语','中国','两位京剧演员跨越半个世纪的悲欢离合。',10.0,'https://raw.githubusercontent.com/AKTNL/images/refs/heads/main/covers/concubina.jpg'),(3,'盗梦空间',2010,148,'科幻/悬疑','英语','美国','通过潜入梦境窃取和植入思想的冒险故事。',4.5,'https://raw.githubusercontent.com/AKTNL/images/refs/heads/main/covers/inception.jpg'),(4,'哪吒之魔童闹海',2025,144,'动画 / 奇幻 / 动作','汉语','中国','讲述了哪吒在经历“天劫”事件后，重塑肉身，与家人共同面对新的考验。他将与龙王敖广的宿怨彻底了结，并在东海之上展开一场惊天动地的大战，真正实现成长，承担起英雄的责任。',9.5,'https://i.ibb.co/SDMd7VqN/nezha2.jpg'),(10,'奥本海默',2023,180,'剧情 / 传记 / 历史','英语','美国 / 英国','聚焦“原子弹之父”罗伯特·奥本海默的传记惊悚片...',9.0,'https://i.ibb.co/1JmDrBv1/oppenheimer.jpg'),(11,'瞬息全宇宙',2022,139,'奇幻 / 动作 / 冒险','英语 / 汉语 / 粤语','美国','一名被生活折腾得筋疲力尽的华裔女子，突然被告知多元宇宙中存在着无数个自己，而她必须去拯救这一切。一场脑洞大开、感人至深的冒险就此展开。',10.0,'https://i.ibb.co/XktBsJww/Everything-Everywhere-All-at-Once.jpg'),(12,'蜘蛛侠：纵横宇宙',2023,140,'动画 / 动作 / 科幻','英语','美国','小黑蛛迈尔斯·莫拉莱斯再次穿越多元宇宙，与各种蜘蛛侠相遇，但他发现自己所做的选择与所有蜘蛛侠都相悖，并与他们产生了激烈冲突。',9.0,'https://i.ibb.co/8Dc0z1Qx/spiderman-across-the-Spider-Verse.webp'),(13,'寄生虫',2019,132,'剧情 / 喜剧','韩语','韩国','讲述了住在廉价半地下室里的一家四口，通过伪造身份，像寄生虫一样进入富裕的朴社长家工作后，发生的一连串意外事件。',9.0,'https://i.ibb.co/WNjLDybG/parasite.jpg'),(14,'让子弹飞',2010,132,'剧情 / 喜剧 / 动作 / 西部','汉语','中国','讲述了悍匪张麻子摇身一变化名清官，带着手下赶赴鹅城上任，与城中的恶霸黄四郎展开一场激烈、荒诞斗争的故事。',0.0,'https://i.ibb.co/39Wgjp6V/Let-the-Bullets-Fly.jpg'),(15,'长津湖',2021,176,'剧情 / 历史 / 战争','汉语 / 英语','中国','电影以抗美援朝战争中的长津湖战役为背景，讲述了一段波澜壮阔的历史：中国人民志愿军第9兵团的英雄儿女们，在极寒严酷环境下，凭着钢铁意志和英勇无畏的战斗精神，扭转了战场态势，为战争胜利作出了重要贡献。',9.0,'https://i.ibb.co/Z6GYdw8d/The-Battle-at-Lake-Changjin.jpg'),(16,'战狼2',2017,123,'动作 / 战争','汉语 / 英语','中国','故事讲述了脱下军装的冷锋被卷入了一场非洲国家的叛乱，本可以安全撤离，却因无法忘记曾经的军人使命，孤身犯险冲回沦陷区，带领身陷屠杀的同胞和难民，展开生死逃亡。',0.0,'https://i.ibb.co/j98HHJVt/Wolf-Warriors-2.jpg'),(17,'流浪地球',2019,125,'科幻 / 灾难','汉语 / 英语 / 俄语 / 法语 / 日语 / 韩语 / 印尼语','中国大陆','太阳即将毁灭，人类在地球表面建造出巨大的推进器，寻找新的家园。然而宇宙之路危机四伏，为了拯救地球，为了人类能在漫长的2500年后抵达新家园，流浪地球时代的年轻人挺身而出，展开争分夺秒的生死之战。',8.0,'https://i.ibb.co/DDcjzkPx/the-wandering-earth.jpg'),(18,'你好，李焕英',2021,128,'剧情 / 喜剧 / 奇幻','汉语','中国大陆','刚考上大学的女孩贾晓玲，在经历母亲遭遇严重意外后，情绪崩溃的状态下，意外地穿越回了1981年，并与年轻时的母亲李焕英相遇，两人形同姐妹。晓玲以为她可以凭借自己超前的思维，让母亲“再活一次”，但结果却出乎意料。',9.3,'https://i.ibb.co/mC7LMy7L/Hi-Mom.jpg'),(21,'低俗小说',1994,154,'剧情 / 喜剧 / 犯罪','英语','美国','由“文森特和马沙的妻子”、“金表”、“邦妮的处境”三个故事以及影片首尾的序幕和尾声五个部分组成。',8.9,'https://img9.doubanio.com/view/photo/s_ratio_poster/public/p1910902213.webp'),(22,'千与千寻',2001,125,'剧情 / 动画 / 奇幻','日语','日本','讲述了少女千寻意外来到神灵异世界后，为了救爸爸妈妈，经历了很多磨难的故事。',9.4,'https://i.ibb.co/rG463BZC/Spirited-away.jpg');

INSERT INTO `directors` VALUES (1,'弗兰克·德拉邦特','男','1959-01-28','美国'),(2,'陈凯歌','男','1952-08-12','中国'),(3,'克里斯托弗·诺兰','男','1970-07-30','英国'),(4,'饺子','男','1980-01-31','中国'),(5,'基斯杜化·诺兰','男','1974-09-23','美国'),(6,'关家永','男','1988-02-10','美国'),(7,'丹尼尔·施纳特','男','1987-06-07','美国'),(8,'乔伊姆·多斯·桑托斯','男','1977-06-22','葡萄牙'),(9,'凯普·鲍尔斯','男','1973-10-30','美国'),(11,'贾斯汀·K·汤普森','男','1981-01-09','美国'),(12,'奉俊昊','男','1969-09-14','韩国'),(13,'姜文','男','1963-01-05','中国'),(15,'徐克','男','1951-02-15','中国'),(16,'林超贤','男','1964-07-01','中国'),(17,'吴京','男','1974-04-03','中国'),(18,'郭帆','男','1980-12-15','中国'),(20,'贾玲','女','1982-04-29','中国'),(21,'弗朗西斯·福特·科波拉','男','1939-04-07','美国'),(22,'昆汀·塔伦蒂诺','男','1963-03-27','美国'),(23,'宫崎骏','男','1941-01-05','日本');

INSERT INTO `actors` VALUES (1,'蒂姆·罗宾斯','男','1958-10-16','美国'),(2,'张国荣','男','1956-09-12','中国'),(3,'莱昂纳多·迪卡普里奥','男','1974-11-11','美国'),(4,'吕艳婷','女','1987-05-19','中国'),(6,'囧森瑟夫','男','1990-10-05','中国'),(7,'瀚墨','男','1994-05-10','中国'),(8,'陈浩','男','1979-02-14','中国'),(9,'绿绮','女','1998-05-30','中国'),(10,'基利安·墨菲','男','1976-05-25','爱尔兰'),(11,'艾米莉·布朗特','女','1983-02-23','英国'),(12,'马特·达蒙','男','1970-10-08','美国'),(13,'小罗伯特·唐尼','男','1965-04-04','美国'),(14,'杨紫琼','女','1962-08-06','马来西亚'),(15,'关继威','男','1971-08-20','美国'),(16,'斯蒂芬妮·安·许','女','1990-11-25','美国'),(17,'珍妮·斯蕾特','女','1982-03-25','美国'),(18,'岑勇康','男','1982-04-28','美国'),(19,'吴汉章','男','1929-02-22','美国'),(20,'杰米·李·柯蒂斯','女','1958-11-22','美国'),(21,'沙梅克·摩尔','男','1995-05-04','美国'),(22,'海莉·斯坦菲尔德','女','1996-12-11','美国'),(23,'布莱恩·泰里·亨利','男','1982-03-31','美国'),(24,'宋康昊','男','1967-01-17','韩国'),(25,'李善均','男','1975-03-02','韩国'),(26,'曹汝贞','女','1981-02-10','韩国'),(27,'崔宇植','男','1990-03-26','韩国'),(28,'朴素丹','女','1991-09-08','韩国'),(29,'张慧珍','女','1975-09-05','韩国'),(30,'朴明勋','男','1975-05-28','韩国'),(31,'李姃垠','女','1970-01-23','韩国'),(32,'姜文','男','1963-01-05','中国'),(33,'周润发','男','1955-05-18','中国'),(34,'葛优','男','1957-04-19','中国'),(35,'刘嘉玲','女','1965-12-08','中国'),(36,'陈坤','男','1976-02-04','中国'),(37,'周韵','女','1978-12-17','中国'),(38,'廖凡','男','1974-02-14','中国'),(39,'姜武','男','1967-11-04','中国'),(40,'吴京','男','1974-04-03','中国'),(41,'易烊千玺','男','2000-11-28','中国'),(42,'段奕宏','男','1973-05-16','中国'),(43,'弗兰克·格里罗','男','1965-06-08','美国'),(44,'吴刚','男','1962-12-09','中国'),(45,'张翰','男','1984-10-06','中国'),(46,'卢靖姗','女','1985-06-10','中国'),(47,'屈楚萧','男','1994-12-28','中国'),(48,'李光洁','男','1981-04-23','中国'),(49,'吴孟达','男','1952-01-02','中国'),(50,'赵今麦','女','2002-09-29','中国'),(51,'沈腾','男','1979-10-23','中国'),(52,'陈赫','男','1985-11-09','中国'),(53,'张小斐','女','1986-01-10','中国'),(54,'贾玲','女','1982-04-29','中国'),(55,'马龙·白兰度','男','1924-04-03','美国'),(56,'阿尔·帕西诺','男','1940-04-25','美国'),(57,'约翰·特拉沃尔塔','男','1954-02-18','美国'),(58,'乌玛·瑟曼','女','1970-04-29','美国');

INSERT INTO `movieactors` VALUES (1,1),(2,2),(3,3),(4,4),(4,6),(4,7),(4,8),(4,9),(10,10),(10,11),(10,12),(10,13),(11,14),(11,15),(11,16),(11,17),(11,18),(11,19),(11,20),(12,21),(12,22),(12,23),(13,24),(13,25),(13,26),(13,27),(13,28),(13,29),(13,30),(13,31),(14,32),(14,33),(14,34),(14,35),(14,36),(14,37),(14,38),(14,39),(15,40),(16,40),(17,40),(15,41),(15,42),(16,43),(16,44),(16,45),(17,47),(17,48),(17,49),(17,50),(18,51),(18,52),(18,53),(18,54),(21,57);

INSERT INTO `moviedirectors` VALUES (1,1),(2,2),(15,2),(3,3),(10,3),(4,4),(11,6),(11,7),(12,8),(12,9),(12,11),(13,12),(14,13),(15,15),(15,16),(16,17),(17,18),(18,20),(21,22),(22,23);

INSERT INTO `users` VALUES (1,'user1','123456','user1@example.com','2025-05-23 09:05:04','user',NULL),(2,'user2','abcdef','user2@example.com','2025-05-23 09:05:04','user',NULL),(3,'user3','qwerty','user3@example.com','2025-05-23 09:05:04','user',NULL),(4,'white_tree','83fb0878b67c9564236510f57e16ad61','ck2474508686@163.com','2025-05-23 09:18:55','admin','https://i.ibb.co/nscW00v8/white-tree.jpg'),(5,'111111','96e79218965eb72c92a549dd5a330112','122111@qq.com','2025-06-18 17:58:50','user','https://i.ibb.co/yF6bmgR6/111111.jpg'),(6,'222222','e3ceb5881a0a1fdaad01296d7554868d',NULL,'2025-06-20 08:26:17','user',NULL),(7,'333333','1a100d2c0dab19c4430e7d73762b3423',NULL,'2025-06-20 08:35:33','user',NULL),(9,'12345','827ccb0eea8a706c4c34a16891f84e7b',NULL,'2025-06-20 08:43:21','user',NULL),(12,'zhangsan','01d7f40760960e7bd9443513f22ab9af',NULL,'2025-06-20 09:35:18','user',NULL),(13,'lisi2','b1105db79577f0b9a2e7ce63f902f0af',NULL,'2025-06-20 09:44:00','user',NULL),(15,'L1ngg','25f9e794323b453885f5181f1b624d0b',NULL,'2025-06-20 12:05:05','user',NULL),(16,'czh111','96e79218965eb72c92a549dd5a330112','czh111@qq.com','2025-06-22 10:29:07','user','https://i.ibb.co/3m2b90VB/czh111.jpg'),(17,'czh223','96e79218965eb72c92a549dd5a330112','czh222@qq.com','2025-06-22 10:41:25','user','https://i.ibb.co/gLLYkwXY/czh222.jpg'),(18,'Particle','96e79218965eb72c92a549dd5a330112','Particle111@qq.com','2025-06-22 12:16:03','user','https://i.ibb.co/ksWJnZ5f/Particle.jpg'),(19,'fisherman','e10adc3949ba59abbe56e057f20f883e','fisherman111@qq.com','2025-06-22 14:55:19','user','https://i.ibb.co/8hGcvFs/fisherman.jpg'),(20,'zllll','c33367701511b4f6020ec61ded352059','1@mail.com','2025-06-25 00:13:01','user','https://i.ibb.co/fdgjVxFq/zhaoliang.jpg'),(21,'leijian111','96e79218965eb72c92a549dd5a330112','lei@qq.com','2025-06-25 11:08:17','user','https://i.ibb.co/d4R0N3cB/leijian.jpg');

INSERT INTO `reviews` VALUES (1,1,1,'这部电影教会了我什么是希望。',5.0,'2025-05-23 09:06:42'),(3,3,3,'梦境与现实交织，脑洞大开！',4.5,'2025-05-23 09:06:42'),(6,19,10,'令人震撼的一部电影！',9.0,'2025-06-24 12:14:06'),(8,19,2,'这是真好看！',10.0,'2025-06-24 15:55:54'),(9,5,1,'非常好看！',10.0,'2025-06-24 17:09:42'),(10,5,11,'棒！',10.0,'2025-06-24 17:09:57'),(11,5,12,'剧情非常吸引我',9.0,'2025-06-24 17:10:26'),(12,20,4,'真的是太好看了。看完这个我想去闹海了\n',10.0,'2025-06-25 00:13:48'),(14,20,15,'看的我在电影院里想起立了\n',9.0,'2025-06-25 00:15:58'),(15,5,18,'可以',8.0,'2025-06-25 08:40:59'),(16,5,4,'国产之光！！！',9.0,'2025-06-25 09:05:48'),(18,21,13,'韩国经典电影！',9.0,'2025-06-25 11:10:53'),(19,21,17,'科幻大片！',8.0,'2025-06-25 11:11:31'),(20,21,18,'太感动了！贾玲导演的这部电影是真不错！',10.0,'2025-06-25 11:24:31'),(21,19,18,'我和我妈妈一起去电影院看的，特别特别好看！',10.0,'2025-06-25 11:26:43');
