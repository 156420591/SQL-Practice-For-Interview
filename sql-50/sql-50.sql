
网上流行的sql常见面试50题练习。本文使用的数据库为MySQL 8.0。

### 测试数据介绍

学生表 Student(SId,Sname,Sage,Ssex)。--SId 学生编号,Sname 学生姓名,Sage 出生年月,Ssex 学生性别

课程表 Course(CId,Cname,TId) --CId --课程编号,Cname 课程名称,TId 教师编号

教师表 Teacher(TId,Tname) --TId 教师编号,Tname 教师姓名

成绩表 Score(SId,CId,score) --SId 学生编号,CId 课程编号,score 分数
<!--more-->

测试数据：

```sql
--建表
--学生表
CREATE TABLE `Student`(
	`SId` VARCHAR(20),
	`Sname` VARCHAR(20) NOT NULL DEFAULT '',
	`Sage` VARCHAR(20) NOT NULL DEFAULT '',
	`Ssex` VARCHAR(10) NOT NULL DEFAULT '',
	PRIMARY KEY(`s_id`)
);
--课程表
CREATE TABLE `Course`(
	`CId`  VARCHAR(20),
	`Cname` VARCHAR(20) NOT NULL DEFAULT '',
	`TId` VARCHAR(20) NOT NULL,
	PRIMARY KEY(`c_id`)
);
--教师表
CREATE TABLE `Teacher`(
	`Td` VARCHAR(20),
	`Tname` VARCHAR(20) NOT NULL DEFAULT '',
	PRIMARY KEY(`t_id`)
);
--成绩表
CREATE TABLE `Score`(
	`SId` VARCHAR(20),
	`CId`  VARCHAR(20),
	`score` INT(3),
	PRIMARY KEY(`s_id`,`c_id`)
);

--插入学生表测试数据
insert into Student values('01' , '赵雷' , '1990-01-01' , '男');
insert into Student values('02' , '钱电' , '1990-12-21' , '男');
insert into Student values('03' , '孙风' , '1990-12-20' , '男');
insert into Student values('04' , '李云' , '1990-12-06' , '男');
insert into Student values('05' , '周梅' , '1991-12-01' , '女');
insert into Student values('06' , '吴兰' , '1992-01-01' , '女');
insert into Student values('07' , '郑竹' , '1989-01-01' , '女');
insert into Student values('08' , '王菊' , '1990-01-20' , '女');
insert into Student values('09' , '张三' , '2017-12-20' , '女');
insert into Student values('10' , '李四' , '2017-12-25' , '女');
insert into Student values('11' , '李四' , '2012-06-06' , '女');
insert into Student values('12' , '赵六' , '2013-06-13' , '女');
insert into Student values('13' , '孙七' , '2014-06-01' , '女');
--课程表测试数据
insert into Course values('01' , '语文' , '02');
insert into Course values('02' , '数学' , '01');
insert into Course values('03' , '英语' , '03');

--教师表测试数据
insert into Teacher values('01' , '张三');
insert into Teacher values('02' , '李四');
insert into Teacher values('03' , '王五');

--成绩表测试数据
insert into Score values('01' , '01' , 80);
insert into Score values('01' , '02' , 90);
insert into Score values('01' , '03' , 99);
insert into Score values('02' , '01' , 70);
insert into Score values('02' , '02' , 60);
insert into Score values('02' , '03' , 80);
insert into Score values('03' , '01' , 80);
insert into Score values('03' , '02' , 80);
insert into Score values('03' , '03' , 80);
insert into Score values('04' , '01' , 50);
insert into Score values('04' , '02' , 30);
insert into Score values('04' , '03' , 20);
insert into Score values('05' , '01' , 76);
insert into Score values('05' , '02' , 87);
insert into Score values('06' , '01' , 31);
insert into Score values('06' , '03' , 34);
insert into Score values('07' , '02' , 89);
insert into Score values('07' , '03' , 98);


--Student表内容：
mysql> SELECT * FROM Student ORDER BY SId;
+------+--------+---------------------+------+
| SId  | Sname  | Sage                | Ssex |
+------+--------+---------------------+------+
| 01   | 赵雷   | 1990-01-01 00:00:00 | 男   |
| 02   | 钱电   | 1990-12-21 00:00:00 | 男   |
| 03   | 孙风   | 1990-12-20 00:00:00 | 男   |
| 04   | 李云   | 1990-12-06 00:00:00 | 男   |
| 05   | 周梅   | 1991-12-01 00:00:00 | 女   |
| 06   | 吴兰   | 1992-01-01 00:00:00 | 女   |
| 07   | 郑竹   | 1989-01-01 00:00:00 | 女   |
| 09   | 张三   | 2017-12-20 00:00:00 | 女   |
| 10   | 李四   | 2017-12-25 00:00:00 | 女   |
| 11   | 李四   | 2012-06-06 00:00:00 | 女   |
| 12   | 赵六   | 2013-06-13 00:00:00 | 女   |
| 13   | 孙七   | 2014-06-01 00:00:00 | 女   |
+------+--------+---------------------+------+

--分数表内容：
mysql> SELECT * FROM Score ORDER BY SId, CId, score DESC;
+------+------+-------+
| SId  | CId  | score |
+------+------+-------+
| 01   | 01   |  80.0 |
| 01   | 02   |  90.0 |
| 01   | 03   |  99.0 |
| 02   | 01   |  70.0 |
| 02   | 02   |  60.0 |
| 02   | 03   |  80.0 |
| 03   | 01   |  80.0 |
| 03   | 02   |  80.0 |
| 03   | 03   |  80.0 |
| 04   | 01   |  50.0 |
| 04   | 02   |  30.0 |
| 04   | 03   |  20.0 |
| 05   | 01   |  76.0 |
| 05   | 02   |  87.0 |
| 06   | 01   |  31.0 |
| 06   | 03   |  34.0 |
| 07   | 02   |  89.0 |
| 07   | 03   |  98.0 |
+------+------+-------+

--课程表内容：
mysql> SELECT * FROM Course ORDER BY CId;
+------+--------+------+
| CId  | Cname  | TId  |
+------+--------+------+
| 01   | 语文   | 02   |
| 02   | 数学   | 01   |
| 03   | 英语   | 03   |
+------+--------+------+

--教师表内容：
mysql> SELECT * FROM Teacher;
+------+--------+
| TId  | Tname  |
+------+--------+
| 01   | 张三   |
| 02   | 李四   |
| 03   | 王五   |
+------+--------+
```
### 1. 查询" 01 "课程比" 02 "课程成绩高的学生的信息及课程分数

解题思路：

首先找出选了01课程和02课程的学生及分数：
```sql
SELECT * 
FROM (
    SELECT SId, CId, score
    FROM Score
    WHERE CId = '01'
) AS a
INNER JOIN (
    SELECT SId, CId, score
    FROM Score
    WHERE CId = '02'
) AS b
ON a.SId = b.SId;

```
得到信息如下：
```
+------+------+-------+------+------+-------+
| SId  | CId  | score | SId  | CId  | score |
+------+------+-------+------+------+-------+
| 01   | 01   |  80.0 | 01   | 02   |  90.0 |
| 02   | 01   |  70.0 | 02   | 02   |  60.0 |
| 03   | 01   |  80.0 | 03   | 02   |  80.0 |
| 04   | 01   |  50.0 | 04   | 02   |  30.0 |
| 05   | 01   |  76.0 | 05   | 02   |  87.0 |
+------+------+-------+------+------+-------+
```
然后把这个表和学生信息表连接:
```sql
SELECT *
FROM Student AS s
INNER JOIN 
    (
        SELECT SId, CId, score
        FROM Score
        WHERE CId = '01'
    ) AS a
INNER JOIN 
    (
        SELECT SId, CId, score
        FROM Score
        WHERE CId = '02'
    ) AS b
ON s.SId = a.SId
AND a.SId = b.SId;
```
得到如下信息：
```
+------+--------+---------------------+------+------+------+-------+------+------+-------+
| SId  | Sname  | Sage                | Ssex | SId  | CId  | score | SId  | CId  | score |
+------+--------+---------------------+------+------+------+-------+------+------+-------+
| 01   | 赵雷   | 1990-01-01 00:00:00 | 男   | 01   | 01   |  80.0 | 01   | 02   |  90.0 |
| 02   | 钱电   | 1990-12-21 00:00:00 | 男   | 02   | 01   |  70.0 | 02   | 02   |  60.0 |
| 03   | 孙风   | 1990-12-20 00:00:00 | 男   | 03   | 01   |  80.0 | 03   | 02   |  80.0 |
| 04   | 李云   | 1990-12-06 00:00:00 | 男   | 04   | 01   |  50.0 | 04   | 02   |  30.0 |
| 05   | 周梅   | 1991-12-01 00:00:00 | 女   | 05   | 01   |  76.0 | 05   | 02   |  87.0 |
+------+--------+---------------------+------+------+------+-------+------+------+-------+
```
最后使用where条件，过滤出01课程分数大于02课程分数的。

```sql

SELECT s.*, a.score AS "01课程成绩", b.score AS "02课程成绩"
FROM Student AS s
INNER JOIN 
    (
        SELECT SId, CId, score
        FROM Score
        WHERE CId = '01'
    ) AS a
INNER JOIN 
    (
        SELECT SId, CId, score
        FROM Score
        WHERE CId = '02'
    ) AS b
ON s.SId = a.SId
AND a.SId = b.SId
WHERE a.score > b.score;
```
最终结果：
```
+------+--------+---------------------+------+----------------+----------------+
| SId  | Sname  | Sage                | Ssex | 01课程成绩     | 02课程成绩     |
+------+--------+---------------------+------+----------------+----------------+
| 02   | 钱电   | 1990-12-21 00:00:00 | 男   |           70.0 |           60.0 |
| 04   | 李云   | 1990-12-06 00:00:00 | 男   |           50.0 |           30.0 |
+------+--------+---------------------+------+----------------+----------------+
```

### 2. 查询" 01 "课程比" 02 "课程成绩低的学生的信息及课程分数

思路：与上一题类似
代码：
```sql
SELECT s.*, a.score AS "01课程成绩", b.score AS "02课程成绩"
FROM Student AS s
INNER JOIN 
    (
        SELECT SId, CId, score
        FROM Score
        WHERE CId = '01'
    ) AS a
INNER JOIN 
    (
        SELECT SId, CId, score
        FROM Score
        WHERE CId = '02'
    ) AS b
ON s.SId = a.SId
AND a.SId = b.SId
WHERE a.score < b.score;
```
结果：
```
+------+--------+---------------------+------+----------------+----------------+
| SId  | Sname  | Sage                | Ssex | 01课程成绩     | 02课程成绩     |
+------+--------+---------------------+------+----------------+----------------+
| 01   | 赵雷   | 1990-01-01 00:00:00 | 男   |           80.0 |           90.0 |
| 05   | 周梅   | 1991-12-01 00:00:00 | 女   |           76.0 |           87.0 |
+------+--------+---------------------+------+----------------+----------------+

```

### 3. 查询同时选了" 01 "课程和" 02 "课程的情况

解题思路：找出选了01课程的表a，找出选了02课程的表b，把这两表连接，其中学生SId相同。

代码：
```sql
SELECT * 
FROM (
        SELECT SId, CId, score AS "01课程成绩"
        FROM Score
        WHERE CId = '01'
    ) AS a
INNER JOIN 
    (
        SELECT SId, CId, score AS "02课程成绩"
        FROM Score
        WHERE CId = '02'
    ) AS b
ON a.SId = b.SId;
```

结果：
```
+------+------+----------------+------+------+----------------+
| SId  | CId  | 01课程成绩     | SId  | CId  | 02课程成绩     |
+------+------+----------------+------+------+----------------+
| 01   | 01   |           80.0 | 01   | 02   |           90.0 |
| 02   | 01   |           70.0 | 02   | 02   |           60.0 |
| 03   | 01   |           80.0 | 03   | 02   |           80.0 |
| 04   | 01   |           50.0 | 04   | 02   |           30.0 |
| 05   | 01   |           76.0 | 05   | 02   |           87.0 |
+------+------+----------------+------+------+----------------+
```

### 4. 查询不存在" 01 "课程但存在" 02 "课程的情况

解题思路：找出选择了02课程的学生，这些学生不在(NOT IN)选了01课程的学生名单中。

代码：
```sql
SELECT SId, CId, score AS "02课程成绩"
FROM Score
WHERE CId = '02'
AND SId NOT IN (
    SELECT SId
    FROM Score
    WHERE CId = '01'
);

```
结果：
```
+------+------+----------------+
| SId  | CId  | 02课程成绩     |
+------+------+----------------+
| 07   | 02   |           89.0 |
+------+------+----------------+

```
### 5. 查询学过编号为"01"但是没有学过编号为"02"的课程的同学的信息

解题思路：和4题类似，只是需要额外与Student表连接，找出学生信息

代码：
```sql
SELECT s.*, t.CId, t.score AS "01课程成绩"
FROM Student AS s 
INNER JOIN 
    (
        SELECT *
        FROM Score
        WHERE CId = '01'
        AND SId NOT IN 
        (
            SELECT SId
            FROM Score
            WHERE CId = '02'
        ) 
    )AS t
ON s.SId = t.SId;
```

结果：
```
+------+--------+---------------------+------+------+----------------+
| SId  | Sname  | Sage                | Ssex | CId  | 01课程成绩     |
+------+--------+---------------------+------+------+----------------+
| 06   | 吴兰   | 1992-01-01 00:00:00 | 女   | 01   |           31.0 |
+------+--------+---------------------+------+------+----------------+
```

### 6. 查询存在" 01 "课程但可能不存在" 02 "课程的情况(不存在时显示为null)

解题思路：找出选01课程的课程信息表a，找出选了02课程的课程信息表b，以表a为主表，使用LEFT JOIN连接，

代码：
```sql
SELECT *
FROM 
(
    SELECT *
    FROM Score
    WHERE CId = '01'
) AS a
LEFT JOIN
(
    SELECT *
    FROM Score
    WHERE CId = '02'
) AS b
ON a.SId = b.SId;
```

结果：
```
+------+------+-------+------+------+-------+
| SId  | CId  | score | SId  | CId  | score |
+------+------+-------+------+------+-------+
| 01   | 01   |  80.0 | 01   | 02   |  90.0 |
| 02   | 01   |  70.0 | 02   | 02   |  60.0 |
| 03   | 01   |  80.0 | 03   | 02   |  80.0 |
| 04   | 01   |  50.0 | 04   | 02   |  30.0 |
| 05   | 01   |  76.0 | 05   | 02   |  87.0 |
| 06   | 01   |  31.0 | NULL | NULL |  NULL |
+------+------+-------+------+------+-------+

```
### 7. 查询平均成绩大于等于 60 分的同学的学生编号和学生姓名和平均成绩

解题思路：涉及到student表和score表，先把这两张表连接起来。因为要求每个学生的各科的平均成绩，因此对学生分组，设置分组条件为平均成绩大于等于 60 分。

代码：
```sql
SELECT st.SId, st.Sname, ROUND(AVG(sc.score), 2) as 'avg_score'
FROM Score AS sc INNER JOIN Student AS st
ON sc.SId = st.SId
GROUP BY st.SId, st.Sname
HAVING avg_score >= 60;
```

结果：
```
+------+--------+-----------+
| SId  | Sname  | avg_score |
+------+--------+-----------+
| 01   | 赵雷   |     89.67 |
| 02   | 钱电   |     70.00 |
| 03   | 孙风   |     80.00 |
| 05   | 周梅   |     81.50 |
| 07   | 郑竹   |     93.50 |
+------+--------+-----------+
```

### 8. 查询所有课程成绩小于 60 分的同学的学生编号和学生姓名和成绩，如果没有成绩，则显示null

解题思路：成绩小于60分为两种情况，一种是有成绩，且小于60;另一种是没有成绩,对于这些学生，TA的SId存在但是score不存在，因此使用student表 LEFT JOIN score表。

代码：
```sql
SELECT st.SId, st.Sname, sc.score
FROM Student AS st LEFT JOIN Score AS sc 
ON sc.SId = st.SId
WHERE sc.score IS NULL OR sc.score < 60;
```

结果：
```
+------+--------+-------+
| SId  | Sname  | score |
+------+--------+-------+
| 04   | 李云   |  50.0 |
| 04   | 李云   |  30.0 |
| 06   | 吴兰   |  31.0 |
| 04   | 李云   |  20.0 |
| 06   | 吴兰   |  34.0 |
| 09   | 张三   |  NULL |
| 10   | 李四   |  NULL |
| 11   | 李四   |  NULL |
| 12   | 赵六   |  NULL |
| 13   | 孙七   |  NULL |
+------+--------+-------+
```

### 9. 查询在 Score 表存在成绩的学生信息

解题思路：有两种方法，一种是用IN, (Student表中的学生ID) IN (Score表中存在成绩的学生ID)。
第二种方法是把两个表连接，以Student表为主表，左连接Score，如果不存在成绩那么score为null，存在成绩，则score IS NOT NULL

代码：
```sql
-- 方法一
SELECT *
FROM Student
WHERE SId IN (
    SELECT SId
    FROM Score
    WHERE score IS NOT NULL
);

-- 方法二
SELECT DISTINCT st.*
FROM Student AS st LEFT JOIN Score AS sc ON st.SId=sc.SId 
WHERE sc.score IS NOT NULL;
```

结果：
```
+------+--------+---------------------+------+
| SId  | Sname  | Sage                | Ssex |
+------+--------+---------------------+------+
| 01   | 赵雷   | 1990-01-01 00:00:00 | 男   |
| 02   | 钱电   | 1990-12-21 00:00:00 | 男   |
| 03   | 孙风   | 1990-12-20 00:00:00 | 男   |
| 04   | 李云   | 1990-12-06 00:00:00 | 男   |
| 05   | 周梅   | 1991-12-01 00:00:00 | 女   |
| 06   | 吴兰   | 1992-01-01 00:00:00 | 女   |
| 07   | 郑竹   | 1989-01-01 00:00:00 | 女   |
+------+--------+---------------------+------+

```

### 10. 查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩(没成绩的显示为 0 )

解题思路：把student表和score表连接，其中部分学生没有成绩，即score=null。然后把学生分组，计算每个学生的选课总数和总成绩。

代码：
```sql
SELECT st.SId, st.Sname, COUNT(sc.CId) AS '选课总数', CAST(SUM(COALESCE(sc.score, 0)) as real) AS '总成绩'
FROM Student AS st LEFT JOIN Score AS sc
ON st.SId = sc.SId
GROUP BY st.SId, st.Sname;
```
这里使用了COALESCE()函数，返回参数中的第一个不为NULL的表达式（从左向右），如果传入的参数所有都是null，则返回null。

这个函数在这段sql语句中的作用是如果sc.score不是null，那么返回值是sc.score本身；如果sc.score是null，那么返回给定值0。

结果：
```
+------+--------+--------------+-----------+
| SId  | Sname  | 选课总数     | 总成绩    |
+------+--------+--------------+-----------+
| 01   | 赵雷   |            3 |       269 |
| 02   | 钱电   |            3 |       210 |
| 03   | 孙风   |            3 |       240 |
| 04   | 李云   |            3 |       100 |
| 05   | 周梅   |            2 |       163 |
| 06   | 吴兰   |            2 |        65 |
| 07   | 郑竹   |            2 |       187 |
| 09   | 张三   |            0 |         0 |
| 10   | 李四   |            0 |         0 |
| 11   | 李四   |            0 |         0 |
| 12   | 赵六   |            0 |         0 |
| 13   | 孙七   |            0 |         0 |
+------+--------+--------------+-----------+

```

### 11.查询"李"姓老师的数量 

解题思路：使用LIKE关键字。在MySQL中，通配符`%`可以替代0个或多个字符，通配符`-`替代一个字符。

代码：
```sql
SELECT COUNT(TId) AS '李老师数量'
FROM Teacher
WHERE Tname LIKE '李%';
```

结果：
```
+-----------------+
| 李老师数量      |
+-----------------+
|               1 |
+-----------------+
```
### 12. 查询学过「张三」老师授课的同学的信息

解题思路：直接把四张表连接起来，使用教师名字作为WHERE条件过滤。或者把学生表和分数表连接，课程表和教师表连接，以课程ID作为过滤条件。

代码：
```sql


SELECT st.*
FROM Student AS st INNER JOIN Score AS sc
ON st.SId = sc.SId
WHERE sc.CId IN (
    SELECT C.CId
    FROM Course AS C INNER JOIN Teacher AS T
    ON C.TId = T.TId
    WHERE T.Tname = '张三'
);
```

结果：
```
+------+--------+---------------------+------+
| SId  | Sname  | Sage                | Ssex |
+------+--------+---------------------+------+
| 01   | 赵雷   | 1990-01-01 00:00:00 | 男   |
| 02   | 钱电   | 1990-12-21 00:00:00 | 男   |
| 03   | 孙风   | 1990-12-20 00:00:00 | 男   |
| 04   | 李云   | 1990-12-06 00:00:00 | 男   |
| 05   | 周梅   | 1991-12-01 00:00:00 | 女   |
| 07   | 郑竹   | 1989-01-01 00:00:00 | 女   |
+------+--------+---------------------+------+

```

### 13. 查询没学过「张三」老师授课的同学的信息

解题思路：先把所有学过张三课程的学生id找出来，过程是把course表，teacher表和score表连接，由教师名字-》教师号-》课程ID-》学生，最后在学生表中去掉这些学生，得到的就是没有学过张三课的学生。

代码：
```sql
SELECT *
FROM Student 
WHERE SId NOT IN (
    SELECT sc.SId
    FROM Course AS C INNER JOIN Teacher AS T INNER JOIN Score AS sc
    ON C.TId = T.TId
    AND C.CId = sc.CId
    WHERE T.Tname = '张三'
);

```

结果：
```
+------+--------+---------------------+------+
| SId  | Sname  | Sage                | Ssex |
+------+--------+---------------------+------+
| 06   | 吴兰   | 1992-01-01 00:00:00 | 女   |
| 09   | 张三   | 2017-12-20 00:00:00 | 女   |
| 10   | 李四   | 2017-12-25 00:00:00 | 女   |
| 11   | 李四   | 2012-06-06 00:00:00 | 女   |
| 12   | 赵六   | 2013-06-13 00:00:00 | 女   |
| 13   | 孙七   | 2014-06-01 00:00:00 | 女   |
+------+--------+---------------------+------+

```
### 14. 查询没有学全所有课程的同学的信息

解题思路：先找出总共的课程数量。然后在成绩表中按学生号分组，查询每个学生学习的课程数量是否等于总课程数量。最后在学生信息表中去掉这些学全所有课程的同学，剩下的就是没有学全的。

代码：
```sql
SELECT *
FROM Student
WHERE SId NOT IN
(
    SELECT SId
    FROM Score
    GROUP BY SId
    HAVING COUNT(CId) = (SELECT COUNT(DISTINCT CId) FROM Course)
);

```
结果：
```
+------+--------+---------------------+------+
| SId  | Sname  | Sage                | Ssex |
+------+--------+---------------------+------+
| 05   | 周梅   | 1991-12-01 00:00:00 | 女   |
| 06   | 吴兰   | 1992-01-01 00:00:00 | 女   |
| 07   | 郑竹   | 1989-01-01 00:00:00 | 女   |
| 09   | 张三   | 2017-12-20 00:00:00 | 女   |
| 10   | 李四   | 2017-12-25 00:00:00 | 女   |
| 11   | 李四   | 2012-06-06 00:00:00 | 女   |
| 12   | 赵六   | 2013-06-13 00:00:00 | 女   |
| 13   | 孙七   | 2014-06-01 00:00:00 | 女   |
+------+--------+---------------------+------+
```

### 15. 查询学过编号为"01"但是没有学过编号为"02"的课程的同学的信息

解题思路：把学生表和成绩表连接，找出学过课程Id为01的这些学生，然后在这些学生中，去除学过课程id为02 的学生。

代码：
```sql
SELECT st.*, sc.CId, sc.score
FROM Score AS sc INNER JOIN Student AS st
ON sc.SId = st.SId
WHERE CId = '01'
AND sc.SId NOT IN 
(
    SELECT SId
    FROM Score
    WHERE CId = '02'
);

```

结果：
```
+------+--------+---------------------+------+------+-------+
| SId  | Sname  | Sage                | Ssex | CId  | score |
+------+--------+---------------------+------+------+-------+
| 06   | 吴兰   | 1992-01-01 00:00:00 | 女   | 01   |  31.0 |
+------+--------+---------------------+------+------+-------+
```

### 16.查询至少有一门课与学号为"01"的同学所学相同的同学的信息 

解题思路：把学生表和成绩表连接，找出(成绩表中课程) IN (学号01的学生学习的所有课程)，注意把01学生自己排除掉。

代码：
```sql
SELECT DISTINCT st.*
FROM Student AS st INNER JOIN Score AS sc
ON st.SId = sc.SId
WHERE sc.CId IN (
    SELECT CId
    FROM Score
    WHERE SId = '01'
)
AND sc.SId != '01';
```

结果：
```
+------+--------+---------------------+------+
| SId  | Sname  | Sage                | Ssex |
+------+--------+---------------------+------+
| 02   | 钱电   | 1990-12-21 00:00:00 | 男   |
| 03   | 孙风   | 1990-12-20 00:00:00 | 男   |
| 04   | 李云   | 1990-12-06 00:00:00 | 男   |
| 05   | 周梅   | 1991-12-01 00:00:00 | 女   |
| 06   | 吴兰   | 1992-01-01 00:00:00 | 女   |
| 07   | 郑竹   | 1989-01-01 00:00:00 | 女   |
+------+--------+---------------------+------+
```

### 17. 查询和学号为"01"的同学学习的课程完全相同的其他同学的信息 

解题思路：完全相同有两个条件，一个是课程id相同，一个是课程数量相同。
先查找学号01学习了哪些课程(比如学了1 2 3)，
然后找这样的学生：他们学习的课程和学号01学习的课程有相同的(比如学号02学了1 2 3，学号03学了1 3， 学号04学了1)，注意把学号01自身过滤掉
最后，有相同的课程，但是课程数量可能不一样，因此还需要以课程数量相同作为进一步的筛选条件，得出数量相同并且课程编号相同的学生。

代码：
```sql

SELECT st.SId, st.Sname
FROM Student AS st INNER JOIN Score AS sc
ON st.SId = sc.SId
WHERE sc.CId IN (
    SELECT CId
    FROM Score
    WHERE SId = '01'
)
AND sc.SId != '01'
GROUP BY st.SId, st.Sname
HAVING COUNT(DISTINCT sc.CId) = (SELECT COUNT(DISTINCT CId) FROM Score WHERE SId = '01');
```

结果：
```
+------+--------+
| SId  | Sname  |
+------+--------+
| 02   | 钱电   |
| 03   | 孙风   |
| 04   | 李云   |
+------+--------+
```
### 18. 查询课程编号为“02”的总成绩

解题思路：使用SUM函数

代码：
```sql
SELECT SUM(score) AS '02课程总成绩'
FROM Score
WHERE CId = '02';
```

结果：
```
+-------------------+
| 02课程总成绩      |
+-------------------+
|             436.0 |
+-------------------+
```

### 19. 检索" 01 "课程分数小于 60，按分数降序排列的学生信息

解题思路：

代码：
```sql
SELECT st.*, sc.score AS '01课程分数'
FROM Student AS st INNER JOIN Score AS sc
ON st.SId = sc.SId
WHERE sc.CId = '01' AND sc.score < 60
ORDER BY sc.score DESC;

```

结果：
```
+------+--------+---------------------+------+----------------+
| SId  | Sname  | Sage                | Ssex | 01课程分数     |
+------+--------+---------------------+------+----------------+
| 04   | 李云   | 1990-12-06 00:00:00 | 男   |           50.0 |
| 06   | 吴兰   | 1992-01-01 00:00:00 | 女   |           31.0 |
+------+--------+---------------------+------+----------------+

```
### 20. 查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩

解题思路：先在分数表中找出所有不及格的学生，然后在其中把学生分组，找出每个学生不及格的数量，选择不及格课程数量>=2的学生。
然后把学生表和分数表连接，对学生分组，找出学生id是上一步中不及格>=2的学生id。

代码：
```sql
SELECT st.SId, st.Sname, AVG(sc.score) AS avg_score
FROM Score AS sc INNER JOIN Student AS st
ON sc.SId = st.SId
WHERE st.SId IN (
    SELECT SId
    FROM Score
    WHERE score < 60
    GROUP BY SId
    HAVING COUNT(CId) >= 2
)
GROUP BY st.SId, st.Sname;
```

结果：
```
+------+--------+-----------+
| SId  | Sname  | avg_score |
+------+--------+-----------+
| 04   | 李云   |  33.33333 |
| 06   | 吴兰   |  32.50000 |
+------+--------+-----------+
```

### 21. 按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩

解题思路：把每个学生的平均成绩找出来记为表t，和成绩表连接。

代码：
```sql
SELECT sc.*, t.avg_score
FROM Score as sc 
LEFT JOIN (
    SELECT SId, AVG(score) as avg_score
    FROM Score
    GROUP BY SId
) as t
ON sc.SId = t.SId
ORDER BY avg_score DESC;
```

结果：
```
+------+------+-------+-----------+
| SId  | CId  | score | avg_score |
+------+------+-------+-----------+
| 07   | 03   |  98.0 |  93.50000 |
| 07   | 02   |  89.0 |  93.50000 |
| 01   | 01   |  80.0 |  89.66667 |
| 01   | 02   |  90.0 |  89.66667 |
| 01   | 03   |  99.0 |  89.66667 |
| 05   | 01   |  76.0 |  81.50000 |
| 05   | 02   |  87.0 |  81.50000 |
| 03   | 03   |  80.0 |  80.00000 |
| 03   | 01   |  80.0 |  80.00000 |
| 03   | 02   |  80.0 |  80.00000 |
| 02   | 01   |  70.0 |  70.00000 |
| 02   | 02   |  60.0 |  70.00000 |
| 02   | 03   |  80.0 |  70.00000 |
| 04   | 01   |  50.0 |  33.33333 |
| 04   | 02   |  30.0 |  33.33333 |
| 04   | 03   |  20.0 |  33.33333 |
| 06   | 03   |  34.0 |  32.50000 |
| 06   | 01   |  31.0 |  32.50000 |
+------+------+-------+-----------+
```

### 22. 查询各科成绩最高分、最低分和平均分
以如下形式显示：课程 ID，课程 name，最高分，最低分，平均分，及格率，中等率，优良率，优秀率
及格为>=60，中等为：70-80，优良为：80-90，优秀为：>=90
要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列

解题思路：需要按各科成绩统计，因此首先把课程分组，然后使用COUNT, MAX, MIN, AVG函数计算对应值

及格率的计算公式：这门课及格的人数/选这门课的总人数，其中及格为score>=60

中等率的计算公式：这门课中等的人数/选这门课的总人数，其中中等为s.score >= 70 AND s.score <80

计算过程：
```sql
SUM(IF(s.score >= 60, 1, 0))   -- 得出及格数

SUM(IF(s.score >= 60, 1, 0)) / COUNT(s.SId)   -- 得出及格率

ROUND((SUM(IF(s.score >= 60, 1, 0)) / COUNT(s.SId)) * 100, 2)  --把及格率转换为百分比形式，如0.6667，转为66.67

CONCAT(ROUND((SUM(IF(s.score >= 60, 1, 0)) / COUNT(s.SId)) * 100, 2), '%') AS '及格率'    --用concat加上'%'号
```

代码：
```sql
SELECT 
    c.CId AS '课程ID',
    c.Cname AS '课程名称',
    COUNT(s.SId) AS '选修人数',
    MAX(s.score) AS '最高分',
    MIN(s.score) AS '最低分',
    ROUND(AVG(s.score), 2) AS '平均分',
    CONCAT(ROUND((SUM(IF(s.score >= 60, 1, 0)) / COUNT(s.SId)) * 100, 2), '%') AS '及格率',
    CONCAT(ROUND((SUM(IF(s.score >= 70 AND s.score <80, 1, 0)) / COUNT(s.SId)) * 100, 2), '%') AS '中等率',
    CONCAT(ROUND((SUM(IF(s.score >= 80 AND s.score <90, 1, 0)) / COUNT(s.SId)) * 100, 2), '%') AS '优良率',
    CONCAT(ROUND((SUM(IF(s.score >= 90 AND s.score <=100, 1, 0)) / COUNT(s.SId)) * 100, 2), '%') AS '优秀率'
FROM Score AS s INNER JOIN Course AS c
ON s.CId = c.CId
GROUP BY c.CId, c.Cname
ORDER BY '选修人数' DESC, c.CId;
```

结果：
```
+----------+--------------+--------------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
| 课程ID    | 课程名称     | 选修人数       | 最高分     | 最低分     | 平均分     | 及格率     | 中等率     | 优良率     | 优秀率    |
+----------+--------------+--------------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
| 01       | 语文         |            6 |      80.0 |      31.0 |     64.50 | 66.67%    | 33.33%    | 33.33%    | 0.00%     |
| 02       | 数学         |            6 |      90.0 |      30.0 |     72.67 | 83.33%    | 0.00%     | 50.00%    | 16.67%    |
| 03       | 英语         |            6 |      99.0 |      20.0 |     68.50 | 66.67%    | 0.00%     | 33.33%    | 33.33%    |
+----------+--------------+--------------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
```

### 23. 按各科成绩进行排序，并显示排名，总分重复时保留名次空缺

解题思路：按学科类别显示排名， 使用窗口函数，partition by 课程类别， order by 分数 逆序排列。
总分相同时保留空缺，即1,2,2,4,5这样，使用rank()函数

代码：
```sql
SELECT *, RANK() OVER (partition by CId ORDER BY score DESC) AS '排名'
FROM Score
ORDER BY CId, 排名;
```

结果：
```
+------+------+-------+--------+
| SId  | CId  | score | 排名   |
+------+------+-------+--------+
| 01   | 01   |  80.0 |      1 |
| 03   | 01   |  80.0 |      1 |
| 05   | 01   |  76.0 |      3 |
| 02   | 01   |  70.0 |      4 |
| 04   | 01   |  50.0 |      5 |
| 06   | 01   |  31.0 |      6 |
| 01   | 02   |  90.0 |      1 |
| 07   | 02   |  89.0 |      2 |
| 05   | 02   |  87.0 |      3 |
| 03   | 02   |  80.0 |      4 |
| 02   | 02   |  60.0 |      5 |
| 04   | 02   |  30.0 |      6 |
| 01   | 03   |  99.0 |      1 |
| 07   | 03   |  98.0 |      2 |
| 02   | 03   |  80.0 |      3 |
| 03   | 03   |  80.0 |      3 |
| 06   | 03   |  34.0 |      5 |
| 04   | 03   |  20.0 |      6 |
+------+------+-------+--------+
```

### 24. 按各科成绩进行排序，并显示排名， 总分重复时合并名次

解题思路：与23题大体相同，不同的是总分重复时合并名次，即1,2,2,3,4,5这样，选择dense_rank()函数。

代码：
```sql
SELECT *, DENSE_RANK() OVER (partition by CId ORDER BY score DESC) AS '排名'
FROM Score
ORDER BY CId, 排名;
```

结果：
```
+------+------+-------+--------+
| SId  | CId  | score | 排名   |
+------+------+-------+--------+
| 01   | 01   |  80.0 |      1 |
| 03   | 01   |  80.0 |      1 |
| 05   | 01   |  76.0 |      2 |
| 02   | 01   |  70.0 |      3 |
| 04   | 01   |  50.0 |      4 |
| 06   | 01   |  31.0 |      5 |
| 01   | 02   |  90.0 |      1 |
| 07   | 02   |  89.0 |      2 |
| 05   | 02   |  87.0 |      3 |
| 03   | 02   |  80.0 |      4 |
| 02   | 02   |  60.0 |      5 |
| 04   | 02   |  30.0 |      6 |
| 01   | 03   |  99.0 |      1 |
| 07   | 03   |  98.0 |      2 |
| 02   | 03   |  80.0 |      3 |
| 03   | 03   |  80.0 |      3 |
| 06   | 03   |  34.0 |      4 |
| 04   | 03   |  20.0 |      5 |
+------+------+-------+--------+
```

### 25. 查询学生的总成绩，并进行排名，总分重复时保留名次空缺

解题思路：先把学生分组，计算每个学生的总成绩，然后对分数进行排名，使用rank()窗口函数。

代码：
```sql
SELECT 
    SId,
    SUM(score) AS '总成绩',
    rank() OVER (ORDER BY SUM(score) DESC) AS '排名'
FROM Score
GROUP BY SId;
```

结果：
```
+------+-----------+--------+
| SId  | 总成绩    | 排名   |
+------+-----------+--------+
| 01   |     269.0 |      1 |
| 03   |     240.0 |      2 |
| 02   |     210.0 |      3 |
| 07   |     187.0 |      4 |
| 05   |     163.0 |      5 |
| 04   |     100.0 |      6 |
| 06   |      65.0 |      7 |
+------+-----------+--------+
```
### 26. 查询学生的平均成绩，并进行排名

解题思路：和26题类似。函数换成AVG()

代码：
```sql
SELECT 
    SId,
    AVG(score) AS '平均成绩',
    rank() OVER (ORDER BY AVG(score) DESC) AS '排名'
FROM Score
GROUP BY SId;
```

结果：
```
+------+--------------+--------+
| SId  | 平均成绩      | 排名    |
+------+--------------+--------+
| 07   |     93.50000 |      1 |
| 01   |     89.66667 |      2 |
| 05   |     81.50000 |      3 |
| 03   |     80.00000 |      4 |
| 02   |     70.00000 |      5 |
| 04   |     33.33333 |      6 |
| 06   |     32.50000 |      7 |
+------+--------------+--------+
```

### 27. 统计各科成绩各分数段的人数：课程编号，课程名称，[100-85],[85-70],[70-60],[60-0]及所占百分比

```sql
SUM(IF(s.score >= 60, 1, 0))   -- 得出及格数

SUM(IF(s.score >= 60, 1, 0)) / COUNT(s.SId)   -- 得出及格率

ROUND((SUM(IF(s.score >= 60, 1, 0)) / COUNT(s.SId)) * 100, 2)  --把及格率转换为百分比形式，如0.6667，转为66.67

CONCAT(ROUND((SUM(IF(s.score >= 60, 1, 0)) / COUNT(s.SId)) * 100, 2), '%') AS '及格率'    --用concat加上'%'号
```

解题思路：

代码：
```sql
SELECT 
    c.CId,
    c.Cname,
    CONCAT(ROUND((SUM(CASE WHEN s.score>=85 THEN 1 ELSE 0 END) / COUNT(s.SId)) * 100, 2), '%') AS '[100-85]分数段占比',
    CONCAT(ROUND((SUM(CASE WHEN s.score>=70 AND s.score < 85 THEN 1 ELSE 0 END) / COUNT(s.SId)) * 100, 2), '%') AS '[85-70]分数段占比',
    CONCAT(ROUND((SUM(CASE WHEN s.score>=60 AND s.score < 70 THEN 1 ELSE 0 END) / COUNT(s.SId)) * 100, 2), '%') AS '[70-60]分数段占比',
    CONCAT(ROUND((SUM(CASE WHEN s.score>=0 AND s.score < 60 THEN 1 ELSE 0 END) / COUNT(s.SId)) * 100, 2), '%') AS '[60-0]分数段占比'
FROM Score AS s INNER JOIN Course AS c
ON s.CId = c.CId
GROUP BY c.CId, c.Cname;
```

结果：
```
+------+--------+-------------------------+------------------------+------------------------+-----------------------+
| CId  | Cname  | [100-85]分数段占比       | [85-70]分数段占比        | [70-60]分数段占比       | [60-0]分数段占比        |
+------+--------+-------------------------+------------------------+------------------------+-----------------------+
| 01   | 语文   | 0.00%                   | 66.67%                 | 0.00%                  | 33.33%                |
| 02   | 数学   | 50.00%                  | 16.67%                 | 16.67%                 | 16.67%                |
| 03   | 英语   | 33.33%                  | 33.33%                 | 0.00%                  | 33.33%                |
+------+--------+-------------------------+------------------------+------------------------+-----------------------+
```

### 28. 查询各科成绩前三名的记录

解题思路：首先按学科分组，对每个学科的分数进行排名，得到一个排名列(类似于23题)。然后把这个排名列放在分数表右边。最后过滤出排名为1,2,3的，再用order排序。

代码：
```sql
SELECT s.SId, s.CId, s.score, t.rank
FROM Score as s INNER JOIN (
    SELECT SId, CId, row_number() OVER (partition by CId ORDER BY score DESC) AS 'rank'
    FROM Score
) as t
ON s.SId = t.SId
AND s.CId = t.CId
WHERE t.rank = 1 or t.rank = 2 or t.rank = 3
ORDER BY s.CId, t.rank;
```

第二种方法：
```sql
SELECT *
FROM (
    SELECT SId, CId, score, 
        row_number() OVER (partition by CId order by score DESC) AS 'rank'
    FROM Score 
) as t
WHERE t.rank IN (1,2,3);
```

结果：
```
+------+------+-------+------+
| SId  | CId  | score | rank |
+------+------+-------+------+
| 01   | 01   |  80.0 |    1 |
| 03   | 01   |  80.0 |    2 |
| 05   | 01   |  76.0 |    3 |
| 01   | 02   |  90.0 |    1 |
| 07   | 02   |  89.0 |    2 |
| 05   | 02   |  87.0 |    3 |
| 01   | 03   |  99.0 |    1 |
| 07   | 03   |  98.0 |    2 |
| 02   | 03   |  80.0 |    3 |
+------+------+-------+------+
```

如果不是前3名，而是前3000名，那么上面两种方法就不适用了。因此考虑第三种方法：

```sql
SELECT a.SId, a.CId, a.score
FROM Score AS a
WHERE (
    SELECT COUNT(1)
    FROM Score AS b
    WHERE b.CId = a.CId
    AND b.score > a.score
) < 3
ORDER BY a.CId, a.score DESC;
```

结果：
```
+------+------+-------+
| SId  | CId  | score |
+------+------+-------+
| 01   | 01   |  80.0 |
| 03   | 01   |  80.0 |
| 05   | 01   |  76.0 |
| 01   | 02   |  90.0 |
| 07   | 02   |  89.0 |
| 05   | 02   |  87.0 |
| 01   | 03   |  99.0 |
| 07   | 03   |  98.0 |
| 02   | 03   |  80.0 |
| 03   | 03   |  80.0 |
+------+------+-------+
```
这里的count(1)，1并不是表示第一个字段，而是表示一共有多少符合条件的行。

### 29. 查询所有课程的成绩第2名到第3名的学生信息及该课程成绩

解题思路：和29题一样，只不过需要多连接一个学生表查出学生信息。

代码：
```sql
SELECT st.*, s.CId, s.score, t.rank
FROM Student as st 
INNER JOIN Score as s 
INNER JOIN (
    SELECT SId, CId, row_number() OVER (partition by CId ORDER BY score DESC) AS 'rank'
    FROM Score
) as t
ON st.SId = s.SId
AND s.SId = t.SId
AND s.CId = t.CId
WHERE t.rank = 2 or t.rank = 3
ORDER BY s.CId, t.rank;
```

第二种写法：
```sql
SELECT * 
FROM (
    SELECT 
        st.*, 
        sc.CId, 
        sc.score, 
        row_number() over (partition BY sc.CId ORDER BY sc.score DESC) AS 'rank'
    FROM Score AS sc INNER JOIN Student AS st 
    ON sc.SId = st.SId
) as t
WHERE t.rank IN (2,3);
```

结果：
```
+------+--------+---------------------+------+------+-------+------+
| SId  | Sname  | Sage                | Ssex | CId  | score | rank |
+------+--------+---------------------+------+------+-------+------+
| 03   | 孙风   | 1990-12-20 00:00:00 | 男   | 01   |  80.0 |    2 |
| 05   | 周梅   | 1991-12-01 00:00:00 | 女   | 01   |  76.0 |    3 |
| 07   | 郑竹   | 1989-01-01 00:00:00 | 女   | 02   |  89.0 |    2 |
| 05   | 周梅   | 1991-12-01 00:00:00 | 女   | 02   |  87.0 |    3 |
| 07   | 郑竹   | 1989-01-01 00:00:00 | 女   | 03   |  98.0 |    2 |
| 02   | 钱电   | 1990-12-21 00:00:00 | 男   | 03   |  80.0 |    3 |
+------+--------+---------------------+------+------+-------+------+
```
### 30. 查询每门课选修的学生人数

解题思路：对课程分组，用COUNT计算人数

代码：
```sql
SELECT CId, COUNT(SId) AS '选修人数'
FROM Score
GROUP BY CId;
```

结果：
```
+------+--------------+
| CId  | 选修人数     |
+------+--------------+
| 01   |            6 |
| 02   |            6 |
| 03   |            6 |
+------+--------------+
```

### 31.查询出只修两门课程的学生学号和姓名

解题思路：把学生表和成绩表连接，然后对学生分组，使用COUNT统计每个学生的课程数量，使用HAVING过滤出数量=2的。

代码：
```sql
SELECT st.SId, st.Sname
FROM Score AS sc INNER JOIN Student AS st
ON sc.SId = st.SId
GROUP BY st.SId, st.Sname
HAVING COUNT(sc.CId) = 2;
```

结果：
```
+------+--------+
| SId  | Sname  |
+------+--------+
| 05   | 周梅   |
| 06   | 吴兰   |
| 07   | 郑竹   |
+------+--------+
```

### 32.查询男生、女生人数

解题思路：对性别分组，使用COUNT计算人数。

代码：
```sql
SELECT Ssex AS '性别', COUNT(*) AS '人数'
FROM Student
GROUP BY Ssex;
```

结果：
```
+--------+--------+
| 性别   | 人数   |
+--------+--------+
| 男     |      4 |
| 女     |      8 |
+--------+--------+
```
### 33. 查询名字中含有「风」字的学生信息

解题思路：使用LIKE关键字，使用%

代码：
```sql
SELECT *
FROM Student
WHERE Sname LIKE '%风%';

```

结果：
```
+------+--------+---------------------+------+
| SId  | Sname  | Sage                | Ssex |
+------+--------+---------------------+------+
| 03   | 孙风   | 1990-12-20 00:00:00 | 男   |
+------+--------+---------------------+------+
```

### 34. 查询同名学生名单，并统计同名人数

解题思路：对学生名字分组，使用COUNT统计人数。

代码：
```sql
SELECT Sname, COUNT(SId) AS '同名人数'
FROM Student
GROUP BY Sname
HAVING COUNT(SId) >= 2;
```

结果：
```
+--------+--------------+
| Sname  | 同名人数     |
+--------+--------------+
| 李四   |            2 |
+--------+--------------+
```

**扩展：**求出同名同性的：
```sql
SELECT s1.Sname, s1.Ssex, COUNT(*) AS '同名同性人数'
FROM Student AS s1 INNER JOIN Student AS s2
ON s1.SId != s2.SId AND s1.Sname = s2.Sname AND s1.Ssex = s2.Ssex
GROUP BY s1.Sname, s1.Ssex;
```
结果：
```
+--------+------+--------------------+
| Sname  | Ssex | 同名同性人数       |
+--------+------+--------------------+
| 李四   | 女   |                  2 |
+--------+------+--------------------+
```

### 35. 查询 1990 年出生的学生名单

解题思路：使用YEAR()函数求出日期中关于年份的。

代码：
```sql
SELECT *
FROM Student
WHERE YEAR(Sage) = '1990';

```

结果：
```
+------+--------+---------------------+------+
| SId  | Sname  | Sage                | Ssex |
+------+--------+---------------------+------+
| 01   | 赵雷   | 1990-01-01 00:00:00 | 男   |
| 02   | 钱电   | 1990-12-21 00:00:00 | 男   |
| 03   | 孙风   | 1990-12-20 00:00:00 | 男   |
| 04   | 李云   | 1990-12-06 00:00:00 | 男   |
+------+--------+---------------------+------+
```

### 36. 查询平均成绩大于等于 85 的所有学生的学号、姓名和平均成绩

解题思路：把学生表和分数表连接，对学生分组，求出每个学生的平均成绩，使用HAVING过滤出>=85的。

代码：
```sql
SELECT st.SId, st.Sname, AVG(sc.score) AS 'avg_score'
FROM Student AS st INNER JOIN Score AS sc
ON st.SId = sc.SId
GROUP BY st.SId, st.Sname
HAVING avg_score >= 85;
```

结果：
```
+------+--------+-----------+
| SId  | Sname  | avg_score |
+------+--------+-----------+
| 01   | 赵雷   |  89.66667 |
| 07   | 郑竹   |  93.50000 |
+------+--------+-----------+
```
### 37. 查询课程名称为「数学」，且分数低于 60 的学生姓名和分数

解题思路：把学生表，分数表，课程表连接，使用WHERE过滤条件。

代码：
```sql
SELECT st.Sname, sc.score
FROM Student AS st INNER JOIN Score AS sc INNER JOIN Course AS co
ON st.SId = sc.SId
AND sc.CId = co.CId
WHERE co.Cname = '数学' AND sc.score < 60;

```

结果：
```
+--------+-------+
| Sname  | score |
+--------+-------+
| 李云   |  30.0 |
+--------+-------+
```

### 38. 查询所有学生的课程及分数情况（存在学生没成绩，没选课的情况）

解题思路：需要学生信息，分数信息和课程信息。所以先把三表连接，找出所有学生信息，
```sql
SELECT st.SId, st.Sname
FROM Student AS st 
LEFT JOIN Score AS sc ON st.SId = sc.SId
LEFT JOIN Course AS co ON sc.CId = co.CId
GROUP BY st.SId, st.Sname;
```

然后按课程统计各科分数及总成绩：
```sql
SELECT 
    st.SId, 
    st.Sname,
    SUM(CASE WHEN co.Cname='语文' THEN sc.score ELSE 0 END) AS '语文成绩',
    SUM(CASE WHEN co.Cname='数学' THEN sc.score ELSE 0 END) AS '数学成绩',
    SUM(CASE WHEN co.Cname='英语' THEN sc.score ELSE 0 END) AS '英语成绩',
    SUM(sc.score)  AS '总分'
FROM Student AS st 
LEFT JOIN Score AS sc ON st.SId = sc.SId
LEFT JOIN Course AS co ON sc.CId = co.CId
GROUP BY st.SId, st.Sname;
```
其中，每个学生的各科成绩只有一门，为了在学生分组中取出这门成绩使用SUM函数，而不是为了对该科成绩求和。
得到结果如下：
```
+------+--------+--------------+--------------+--------------+--------+
| SId  | Sname  | 语文成绩     | 数学成绩     | 英语成绩     | 总分   |
+------+--------+--------------+--------------+--------------+--------+
| 01   | 赵雷   |         80.0 |         90.0 |         99.0 |  269.0 |
| 02   | 钱电   |         70.0 |         60.0 |         80.0 |  210.0 |
| 03   | 孙风   |         80.0 |         80.0 |         80.0 |  240.0 |
| 04   | 李云   |         50.0 |         30.0 |         20.0 |  100.0 |
| 05   | 周梅   |         76.0 |         87.0 |          0.0 |  163.0 |
| 06   | 吴兰   |         31.0 |          0.0 |         34.0 |   65.0 |
| 07   | 郑竹   |          0.0 |         89.0 |         98.0 |  187.0 |
| 09   | 张三   |          0.0 |          0.0 |          0.0 |   NULL |
| 10   | 李四   |          0.0 |          0.0 |          0.0 |   NULL |
| 11   | 李四   |          0.0 |          0.0 |          0.0 |   NULL |
| 12   | 赵六   |          0.0 |          0.0 |          0.0 |   NULL |
| 13   | 孙七   |          0.0 |          0.0 |          0.0 |   NULL |
+------+--------+--------------+--------------+--------------+--------+
```
接下来对数据处理，第一步，把总分中的NULL转换为0，需要用COALESCE()函数。第二步，去除小数点后的0，使用CAST函数，

代码：
```sql
SELECT 
    st.SId, 
    st.Sname,
    CAST(SUM(CASE WHEN co.Cname='语文' THEN sc.score ELSE 0 END) as real) AS '语文成绩',
    CAST(SUM(CASE WHEN co.Cname='数学' THEN sc.score ELSE 0 END) as real) AS '数学成绩',
    CAST(SUM(CASE WHEN co.Cname='英语' THEN sc.score ELSE 0 END) as real) AS '英语成绩',
    CAST(COALESCE(SUM(sc.score), 0) as real) AS '总分'
FROM Student AS st 
LEFT JOIN Score AS sc ON st.SId = sc.SId
LEFT JOIN Course AS co ON sc.CId = co.CId
GROUP BY st.SId, st.Sname;
```

结果：
```
+------+--------+--------------+--------------+--------------+--------+
| SId  | Sname  | 语文成绩      | 数学成绩      | 英语成绩      | 总分    |
+------+--------+--------------+--------------+--------------+--------+
| 01   | 赵雷   |           80 |           90 |           99 |    269 |
| 02   | 钱电   |           70 |           60 |           80 |    210 |
| 03   | 孙风   |           80 |           80 |           80 |    240 |
| 04   | 李云   |           50 |           30 |           20 |    100 |
| 05   | 周梅   |           76 |           87 |            0 |    163 |
| 06   | 吴兰   |           31 |            0 |           34 |     65 |
| 07   | 郑竹   |            0 |           89 |           98 |    187 |
| 09   | 张三   |            0 |            0 |            0 |      0 |
| 10   | 李四   |            0 |            0 |            0 |      0 |
| 11   | 李四   |            0 |            0 |            0 |      0 |
| 12   | 赵六   |            0 |            0 |            0 |      0 |
| 13   | 孙七   |            0 |            0 |            0 |      0 |
+------+--------+--------------+--------------+--------------+--------+
```

### 39. 查询不同老师所教不同课程平均分从高到低显示

解题思路：把课程表和分数表连接，对老师及所教课程分组，使用AVG()计算平均分，DESC逆序排列。

代码：
```sql
SELECT co.TId, co.CId, AVG(sc.score) AS 'avg_score'
FROM Course AS co INNER JOIN Score AS sc
ON co.CId = sc.CId
GROUP BY co.TId, co.CId
ORDER BY avg_score DESC;
```

结果：
```
+------+------+-----------+
| TId  | CId  | avg_score |
+------+------+-----------+
| 01   | 02   |  72.66667 |
| 03   | 03   |  68.50000 |
| 02   | 01   |  64.50000 |
+------+------+-----------+

```

### 40. 查询任何一门课程成绩在 70 分以上的姓名、课程名称和分数

解题思路：

代码：
```sql
SELECT st.Sname, co.Cname, sc.score
FROM Student AS st 
INNER JOIN Score AS sc ON st.SId = sc.SId
INNER JOIN Course AS co ON sc.CId = co.CId
WHERE sc.score > 70;
```

结果：
```
+--------+--------+-------+
| Sname  | Cname  | score |
+--------+--------+-------+
| 赵雷   | 语文   |  80.0 |
| 赵雷   | 数学   |  90.0 |
| 赵雷   | 英语   |  99.0 |
| 钱电   | 英语   |  80.0 |
| 孙风   | 语文   |  80.0 |
| 孙风   | 数学   |  80.0 |
| 孙风   | 英语   |  80.0 |
| 周梅   | 语文   |  76.0 |
| 周梅   | 数学   |  87.0 |
| 郑竹   | 数学   |  89.0 |
| 郑竹   | 英语   |  98.0 |
+--------+--------+-------+
```

### 41. 查询不及格的课程并按课程号从大到小排列

解题思路：使用WHERE过滤出不及格的课程，DESC从大到小排序。

代码：
```sql
SELECT sc.CId, co.Cname, sc.score
FROM Score AS sc INNER JOIN Course AS co
ON sc.CId = co.CId
WHERE sc.score < 60
ORDER BY sc.CId DESC;
```

结果：
```
+------+--------+-------+
| CId  | Cname  | score |
+------+--------+-------+
| 03   | 英语   |  20.0 |
| 03   | 英语   |  34.0 |
| 02   | 数学   |  30.0 |
| 01   | 语文   |  50.0 |
| 01   | 语文   |  31.0 |
+------+--------+-------+

```

### 42. 查询课程编号为 01 且课程成绩在 80 分以上的学生的学号和姓名

解题思路：把分数表和学生表连接，使用WHERE过滤条件。

代码：
```sql
SELECT st.SId, st.Sname
FROM Score AS sc INNER JOIN Student AS st 
ON st.SId = sc.SId
WHERE sc.CId = '01' AND sc.score >= 80;

```

结果：
```
+------+--------+
| SId  | Sname  |
+------+--------+
| 01   | 赵雷   |
| 03   | 孙风   |
+------+--------+
```

### 43. 成绩不重复，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩

解题思路：首先找出张三老师教的课程编号：
```sql
SELECT co.CId
FROM Course AS co INNER JOIN Teacher AS te
ON co.TId = te.TId
WHERE te.Tname = '张三';
```
得到：
```
+------+
| CId  |
+------+
| 02   |
+------+
```
然后把学生表和成绩表连接，找出成绩表中课程编号是02的所有成绩，取最高的成绩及其学生信息。

代码：
```sql
SELECT st.*, sc.score
FROM Student AS st INNER JOIN Score AS sc
ON st.SId = sc.SId
WHERE sc.CId = (
    SELECT co.CId
    FROM Course AS co INNER JOIN Teacher AS te
    ON co.TId = te.TId
    WHERE te.Tname = '张三'
)
ORDER BY sc.score DESC
LIMIT 0,1;

```

结果：
```
+------+--------+---------------------+------+-------+
| SId  | Sname  | Sage                | Ssex | score |
+------+--------+---------------------+------+-------+
| 01   | 赵雷   | 1990-01-01 00:00:00 | 男   |  90.0 |
+------+--------+---------------------+------+-------+

```

### 44. 成绩有重复的情况下，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩

为了验证本题答案正确性，先把原Score表中的数据做下修改，设张三老师课程下有两个最高分的。
```sql
UPDATE Score SET score=90
where SId = "07"
and CId ="02";
```

解题思路：和44题类似，首先找出张三老师教的课程编号，以及该课程下最高的分数：
```sql
SELECT co.CId
FROM Course AS co INNER JOIN Teacher AS te
ON co.TId = te.TId
WHERE te.Tname = '张三';

SELECT MAX(score)
FROM Score
WHERE CId = (
    SELECT co.CId
    FROM Course AS co INNER JOIN Teacher AS te
    ON co.TId = te.TId
    WHERE te.Tname = '张三'
);

```
得到：
```
+------+
| CId  |
+------+
| 02   |
+------+

+------------+
| MAX(score) |
+------------+
|       90.0 |
+------------+

```
然后，在分数表中筛选出满足这两个条件的：
第一，课程id是张三老师教课的课程id。
```sql
SELECT st.*, sc.score, sc.CId
FROM Student AS st INNER JOIN Score AS sc 
ON st.SId = sc.SId
WHERE sc.CId = (
    SELECT co.CId
    FROM Course AS co INNER JOIN Teacher AS te
    ON co.TId = te.TId
    WHERE te.Tname = '张三'
);

```
得到：
```
+------+--------+---------------------+------+-------+------+
| SId  | Sname  | Sage                | Ssex | score | CId  |
+------+--------+---------------------+------+-------+------+
| 01   | 赵雷   | 1990-01-01 00:00:00 | 男   |  90.0 | 02   |
| 02   | 钱电   | 1990-12-21 00:00:00 | 男   |  60.0 | 02   |
| 03   | 孙风   | 1990-12-20 00:00:00 | 男   |  80.0 | 02   |
| 04   | 李云   | 1990-12-06 00:00:00 | 男   |  30.0 | 02   |
| 05   | 周梅   | 1991-12-01 00:00:00 | 女   |  87.0 | 02   |
| 07   | 郑竹   | 1989-01-01 00:00:00 | 女   |  90.0 | 02   |
+------+--------+---------------------+------+-------+------+
```

第二, 在这个表基础上，找出分数是最高分的

代码：
```sql
SELECT st.*, sc.score, sc.CId
FROM Student AS st INNER JOIN Score AS sc 
ON st.SId = sc.SId
WHERE sc.CId = (
    SELECT co.CId
    FROM Course AS co INNER JOIN Teacher AS te
    ON co.TId = te.TId
    WHERE te.Tname = '张三'
) AND sc.score IN (
    SELECT MAX(score)
    FROM Score
    WHERE CId = (
        SELECT co.CId
        FROM Course AS co INNER JOIN Teacher AS te
        ON co.TId = te.TId
        WHERE te.Tname = '张三'
    )
);

```

结果：
```
+------+--------+---------------------+------+-------+------+
| SId  | Sname  | Sage                | Ssex | score | CId  |
+------+--------+---------------------+------+-------+------+
| 01   | 赵雷   | 1990-01-01 00:00:00 | 男   |  90.0 | 02   |
| 07   | 郑竹   | 1989-01-01 00:00:00 | 女   |  90.0 | 02   |
+------+--------+---------------------+------+-------+------+
```

最后记得把表恢复到原表的成绩：
```sql
UPDATE Score SET score=89
where SId = "07"
and CId ="02";
```

### 45. 查询不同课程成绩相同的学生的学生编号、课程编号、学生成绩

解题思路：首先把分数表自连接成两份sc1和sc2，连接条件设为sc1.score = sc1.score 和 sc1.CId != sc2.CId，
```sql
SELECT sc1.SId, sc1.CId, sc1.score
FROM Score AS sc1 INNER JOIN Score AS sc2
ON sc1.score = sc2.score AND sc1.CId != sc2.CId;
```

得到：
```
+------+------+-------+
| SId  | CId  | score |
+------+------+-------+
| 03   | 02   |  80.0 |
| 02   | 03   |  80.0 |
| 03   | 03   |  80.0 |
| 03   | 02   |  80.0 |
| 02   | 03   |  80.0 |
| 03   | 03   |  80.0 |
| 01   | 01   |  80.0 |
| 03   | 01   |  80.0 |
| 02   | 03   |  80.0 |
| 03   | 03   |  80.0 |
| 01   | 01   |  80.0 |
| 03   | 01   |  80.0 |
| 03   | 02   |  80.0 |
| 01   | 01   |  80.0 |
| 03   | 01   |  80.0 |
| 03   | 02   |  80.0 |
+------+------+-------+
```
然后对SId去重，
代码：
```sql
SELECT DISTINCT sc1.SId, sc1.CId, sc1.score
FROM Score AS sc1 INNER JOIN Score AS sc2
ON sc1.score = sc2.score AND sc1.CId != sc2.CId
```

结果：
```
+------+------+-------+
| SId  | CId  | score |
+------+------+-------+
| 03   | 02   |  80.0 |
| 02   | 03   |  80.0 |
| 03   | 03   |  80.0 |
| 01   | 01   |  80.0 |
| 03   | 01   |  80.0 |
+------+------+-------+
```
### 46. 统计每门课程的学生选修人数（超过5人的课程才统计）。要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列（不重要）

解题思路：对课程进行分组，分组条件设为人数>5。

代码：
```sql
SELECT CId, COUNT(SId) AS 'student_num'
FROM Score
GROUP BY CId
HAVING student_num > 5
ORDER BY student_num DESC, CId;
```

结果：
```
+------+-------------+
| CId  | student_num |
+------+-------------+
| 01   |           6 |
| 02   |           6 |
| 03   |           6 |
+------+-------------+
```


### 47. 检索至少选修两门课程的学生学号

解题思路：对分数表中的学生分组，分组条件设为课程数量>=2。

代码：
```sql
SELECT SId
FROM Score
GROUP BY SId
HAVING COUNT(CId) >= 2;

```

结果：
```
+------+
| SId  |
+------+
| 01   |
| 02   |
| 03   |
| 04   |
| 05   |
| 06   |
| 07   |
+------+
```

### 48. 查询选修了全部课程的学生信息

解题思路：先找出课程表中全部课程总共有多少。然后把学生表和分数表连接，并对学生进行分组，分组后对每个学生设置过滤条件，即该学生选修课程数量=全部课程数量。

代码：
```sql
SELECT st.SId, st.Sname, st.Sage, st.Ssex
FROM Student AS st INNER JOIN Score AS sc
ON st.SId = sc.SId
GROUP BY st.SId, st.Sname, st.Sage, st.Ssex
HAVING COUNT(sc.CId) = (
    SELECT COUNT(CId)
    FROM Course
);

```

结果：
```
+------+--------+---------------------+------+
| SId  | Sname  | Sage                | Ssex |
+------+--------+---------------------+------+
| 01   | 赵雷   | 1990-01-01 00:00:00 | 男   |
| 02   | 钱电   | 1990-12-21 00:00:00 | 男   |
| 03   | 孙风   | 1990-12-20 00:00:00 | 男   |
| 04   | 李云   | 1990-12-06 00:00:00 | 男   |
+------+--------+---------------------+------+
```

### 49.查询没学过“张三”老师讲授的任一门课程的学生姓名

解题思路：首先找出张三讲授的所有课程的id:
```sql
SELECT co.CId
FROM Course AS co INNER JOIN Teacher AS te
ON co.TId = te.TId
WHERE te.Tname = '张三';
```
得到：
```
+------+
| CId  |
+------+
| 02   |
+------+
```

然后，把学生表和成绩表连接：
```sql
SELECT *
FROM Student AS st INNER JOIN Score AS sc
ON st.SId = sc.SId;
```
得到：
```
+------+--------+---------------------+------+------+------+-------+
| SId  | Sname  | Sage                | Ssex | SId  | CId  | score |
+------+--------+---------------------+------+------+------+-------+
| 01   | 赵雷   | 1990-01-01 00:00:00 | 男   | 01   | 01   |  80.0 |
| 01   | 赵雷   | 1990-01-01 00:00:00 | 男   | 01   | 02   |  90.0 |
| 02   | 钱电   | 1990-12-21 00:00:00 | 男   | 02   | 01   |  70.0 |
| 02   | 钱电   | 1990-12-21 00:00:00 | 男   | 02   | 02   |  60.0 |
| 03   | 孙风   | 1990-12-20 00:00:00 | 男   | 03   | 01   |  80.0 |
| 03   | 孙风   | 1990-12-20 00:00:00 | 男   | 03   | 02   |  80.0 |
| 04   | 李云   | 1990-12-06 00:00:00 | 男   | 04   | 01   |  50.0 |
| 04   | 李云   | 1990-12-06 00:00:00 | 男   | 04   | 02   |  30.0 |
| 05   | 周梅   | 1991-12-01 00:00:00 | 女   | 05   | 01   |  76.0 |
| 05   | 周梅   | 1991-12-01 00:00:00 | 女   | 05   | 02   |  87.0 |
| 06   | 吴兰   | 1992-01-01 00:00:00 | 女   | 06   | 01   |  31.0 |
| 07   | 郑竹   | 1989-01-01 00:00:00 | 女   | 07   | 02   |  89.0 |
| 01   | 赵雷   | 1990-01-01 00:00:00 | 男   | 01   | 03   |  99.0 |
| 02   | 钱电   | 1990-12-21 00:00:00 | 男   | 02   | 03   |  80.0 |
| 03   | 孙风   | 1990-12-20 00:00:00 | 男   | 03   | 03   |  80.0 |
| 04   | 李云   | 1990-12-06 00:00:00 | 男   | 04   | 03   |  20.0 |
| 06   | 吴兰   | 1992-01-01 00:00:00 | 女   | 06   | 03   |  34.0 |
| 07   | 郑竹   | 1989-01-01 00:00:00 | 女   | 07   | 03   |  98.0 |
+------+--------+---------------------+------+------+------+-------+
```

在这张表中，找出所有学过ID为02课程的学生。先对学生及其分数分组，设置过滤条件为学过ID为02课程的学生

找出所有学过课程id为02的学生：
```sql
SELECT st.SId, st.Sname
FROM Student AS st INNER JOIN Score AS sc
ON st.SId = sc.SId
GROUP BY st.SId, st.Sname,sc.CId
HAVING sc.CId IN (
    SELECT co.CId
    FROM Course AS co INNER JOIN Teacher AS te
    ON co.TId = te.TId
    WHERE te.Tname = '张三'
);
```
得到：
```
+------+--------+
| SId  | Sname  |
+------+--------+
| 01   | 赵雷   |
| 02   | 钱电   |
| 03   | 孙风   |
| 04   | 李云   |
| 05   | 周梅   |
| 07   | 郑竹   |
+------+--------+
```
最后，在学生表中，把这些学生排除掉，得到的就是没有学过“张三”老师讲授的任一门课程的学生姓名

代码：
```sql
SELECT SId, Sname
FROM Student 
WHERE SId NOT IN (
    SELECT st.SId
    FROM Student AS st INNER JOIN Score AS sc
    ON st.SId = sc.SId
    GROUP BY st.SId, st.Sname,sc.CId
    HAVING sc.CId IN (
        SELECT co.CId
        FROM Course AS co INNER JOIN Teacher AS te
        ON co.TId = te.TId
        WHERE te.Tname = '张三'
    )
);
```

最后结果：
```
+------+--------+
| SId  | Sname  |
+------+--------+
| 06   | 吴兰   |
| 09   | 张三   |
| 10   | 李四   |
| 11   | 李四   |
| 12   | 赵六   |
| 13   | 孙七   |
+------+--------+
```

### 50. 查询两门以上不及格课程的同学的学号及其平均成绩

解题思路：首先查出所有不及格的,再对学生分组，分组条件设为课程>2的。

代码：
```sql
SELECT SId, AVG(score) as avg_score
FROM Score
WHERE score < 60
GROUP BY SId
HAVING COUNT(CId) > 2;

```

结果：
```
+------+-----------+
| SId  | avg_score |
+------+-----------+
| 04   |  33.33333 |
+------+-----------+

```

### 51. 查询各学生的年龄，只按年份来算

解题思路：使用YEAR()函数计算每个日期的年份，

代码：
```sql
SELECT Sname, Sage, YEAR(now()) - YEAR(Sage) as '年龄'
FROM Student;
```

结果：
```
+--------+---------------------+--------+
| Sname  | Sage                | 年龄   |
+--------+---------------------+--------+
| 赵雷   | 1990-01-01 00:00:00 |     29 |
| 钱电   | 1990-12-21 00:00:00 |     29 |
| 孙风   | 1990-12-20 00:00:00 |     29 |
| 李云   | 1990-12-06 00:00:00 |     29 |
| 周梅   | 1991-12-01 00:00:00 |     28 |
| 吴兰   | 1992-01-01 00:00:00 |     27 |
| 郑竹   | 1989-01-01 00:00:00 |     30 |
| 张三   | 2017-12-20 00:00:00 |      2 |
| 李四   | 2017-12-25 00:00:00 |      2 |
| 李四   | 2012-06-06 00:00:00 |      7 |
| 赵六   | 2013-06-13 00:00:00 |      6 |
| 孙七   | 2014-06-01 00:00:00 |      5 |
+--------+---------------------+--------+
```

### 52. 查询各学生的年龄，按出生日期算，当前月日 < 出生年月的月日，则年龄减一

解题思路：这个题目和52题不一样的地方在于，年龄需要加入月日的判断。
今天是2019年11月10日。
假如出生日期是2017年6月1日，当前月日11-10 > 出生月日06-01，ta现在的年龄是2019-11-10减去2017-06-01，结果是2岁
假如出生日期是2017年12月1日， 当前月日11-10 < 出生月日12-01，ta现在的年龄是(2019-11-10减去2017-12-01)再减去1，结果是1岁

代码：
```sql
select 
    Sname,
    Sage,
    (DATE_FORMAT(NOW(),'%Y') - DATE_FORMAT(Sage,'%Y') - 
     (case when 
        DATE_FORMAT(NOW(),'%m%d') < DATE_FORMAT(Sage,'%m%d') 
        then 1 
        else 0 
     end)
    ) as age
from Student;
```

结果：
```
+--------+---------------------+------+
| Sname  | Sage                | age  |
+--------+---------------------+------+
| 赵雷   | 1990-01-01 00:00:00 |   29 |
| 钱电   | 1990-12-21 00:00:00 |   28 |
| 孙风   | 1990-12-20 00:00:00 |   28 |
| 李云   | 1990-12-06 00:00:00 |   28 |
| 周梅   | 1991-12-01 00:00:00 |   27 |
| 吴兰   | 1992-01-01 00:00:00 |   27 |
| 郑竹   | 1989-01-01 00:00:00 |   30 |
| 张三   | 2017-12-20 00:00:00 |    1 |
| 李四   | 2017-12-25 00:00:00 |    1 |
| 李四   | 2012-06-06 00:00:00 |    7 |
| 赵六   | 2013-06-13 00:00:00 |    6 |
| 孙七   | 2014-06-01 00:00:00 |    5 |

```

### 53. 查询本周过生日的学生

解题思路：使用week()函数，查出今天是第几周
```sql
SELECT WEEK(NOW());
```
得到：
```
+-------------+
| WEEK(NOW()) |
+-------------+
|          45 |
+-------------+
```
学生表中的出生日期的第n周 = 今天的第n周
代码：
```sql
SELECT *, week(Sage) AS '出生在第几周'
FROM Student
WHERE WEEK(NOW()) = WEEK(Sage);

```

结果：
```
Empty set (0.00 sec)

```

### 54. 查询下周过生日的学生

解题思路：和54题类似。

代码：
```sql
SELECT *, week(Sage) AS '出生在第几周'
FROM Student
WHERE WEEK(NOW()+1) = WEEK(Sage);

```

结果：
```
Empty set (0.00 sec)
```

### 55. 查询本月过生日的学生

解题思路：首先找出现在是几月：
```sql
SELECT MONTH(NOW());
```
得到：
```
+--------------+
| MONTH(NOW()) |
+--------------+
|           11 |
+--------------+

```
然后，在学生表中，找出出生月份是和本月月份相同的。

代码：
```sql
SELECT *, MONTH(Sage)
FROM Student
WHERE MONTH(Sage) = MONTH(NOW());
```

结果：
```
Empty set (0.00 sec)

```

### 56. 查询下月过生日的学生

解题思路：和56题类似，只不过月份需要加1。

代码：
```sql
SELECT *, MONTH(Sage) AS '出生月份'
FROM Student
WHERE MONTH(Sage) = MONTH(NOW())+1;
```

结果：
```
+------+--------+---------------------+------+--------------+
| SId  | Sname  | Sage                | Ssex | 出生月份     |
+------+--------+---------------------+------+--------------+
| 02   | 钱电   | 1990-12-21 00:00:00 | 男   |           12 |
| 03   | 孙风   | 1990-12-20 00:00:00 | 男   |           12 |
| 04   | 李云   | 1990-12-06 00:00:00 | 男   |           12 |
| 05   | 周梅   | 1991-12-01 00:00:00 | 女   |           12 |
| 09   | 张三   | 2017-12-20 00:00:00 | 女   |           12 |
| 10   | 李四   | 2017-12-25 00:00:00 | 女   |           12 |
+------+--------+---------------------+------+--------------+
```



