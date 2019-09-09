/* 问题描述：
1. 查询" 01 "课程比" 02 "课程成绩高的学生的信息及课程分数
思路： 涉及的表有student和score，先在score表中找出选课程01的学生信息和分数记为表A，再找出选课程02的学生信息和分数记为表B，
将这两张表通过SId关联(JOIN)成一张表，然后以表A中01课程的分数>表B中02课程的分数为过滤条件，得出题目查询结果。

SELECT  st.*, A.score AS "01课程成绩", B.score AS "02课程成绩" FROM 
(SELECT SId, score FROM Score WHERE CId = '01') AS A 
INNER JOIN 
(SELECT SId, score FROM Score WHERE CId = '02') AS B 
ON A.SId = B.SId 
INNER JOIN Student AS st ON st.SId = A.SId
WHERE A.score>B.score;

+------+--------+---------------------+------+----------------+----------------+
| SId  | Sname  | Sage                | Ssex | 01课程成绩     | 02课程成绩     |
+------+--------+---------------------+------+----------------+----------------+
| 02   | 钱电   | 1990-12-21 00:00:00 | 男   |           70.0 |           60.0 |
| 04   | 李云   | 1990-12-06 00:00:00 | 男   |           50.0 |           30.0 |
+------+--------+---------------------+------+----------------+----------------+

1.0 查询" 01 "课程比" 02 "课程成绩低的学生的信息及课程分数

SELECT st.*, A.score AS '01课程分数', B.score AS '02课程分数'
FROM Student AS st 
INNER JOIN (SELECT * FROM Score WHERE CId='01') AS A ON st.SId = A.SId
INNER JOIN (SELECT * FROM Score WHERE CId='02') AS B ON A.SId = B.SId
WHERE A.score<B.score;

+------+--------+---------------------+------+----------------+----------------+
| SId  | Sname  | Sage                | Ssex | 01课程分数     | 02课程分数     |
+------+--------+---------------------+------+----------------+----------------+
| 01   | 赵雷   | 1990-01-01 00:00:00 | 男   |           80.0 |           90.0 |
| 05   | 周梅   | 1991-12-01 00:00:00 | 女   |           76.0 |           87.0 |
+------+--------+---------------------+------+----------------+----------------+

 1.1  查询同时存在" 01 "课程和" 02 "课程的情况
 思路：涉及到表Score，首先找出存在01课程的记为表A，然后找出存在02课程的记为表B，以学生编号SId既在表A又在表B为过滤条件，得出题目查询结果。
 
 SELECT A.SId,A.CId,A.score AS "01课程成绩",B.CId,B.score AS "02课程成绩" FROM
(SELECT * FROM Score WHERE CId='01') AS A, 
(SELECT * FROM Score WHERE CId='02') AS B
WHERE A.SId=B.SId;

+------+------+----------------+------+----------------+
| SId  | CId  | 01课程成绩     | CId  | 02课程成绩     |
+------+------+----------------+------+----------------+
| 01   | 01   |           80.0 | 02   |           90.0 |
| 02   | 01   |           70.0 | 02   |           60.0 |
| 03   | 01   |           80.0 | 02   |           80.0 |
| 04   | 01   |           50.0 | 02   |           30.0 |
| 05   | 01   |           76.0 | 02   |           87.0 |
+------+------+----------------+------+----------------+

1.2 查询不存在" 01 "课程但存在" 02 "课程的情况
思路：涉及到表Score，两个条件是且的关系，先找出选了02课程的学生记为A(A.CId='02' )，再找选了01课程的学生记为B，
最后找选了02课程的学生（A.SId）但没有(NOT IN)选01课程的，得出题目查询结果。

SELECT * 
FROM Score AS A
WHERE A.CId='02' 
AND A.SId NOT IN (SELECT SId FROM Score AS B WHERE B.CID='01');

+------+------+-------+
| SId  | CId  | score |
+------+------+-------+
| 07   | 02   |  89.0 |
+------+------+-------+


查询学过编号为"01"但是没有学过编号为"02"的课程的同学的信息
SELECT * 
FROM Student AS st JOIN Score AS sc ON st.SId=sc.SId 
WHERE sc.CId='01' AND sc.SId NOT IN (SELECT SId FROM Score WHERE CId='02');
+------+--------+---------------------+------+------+------+-------+
| SId  | Sname  | Sage                | Ssex | SId  | CId  | score |
+------+--------+---------------------+------+------+------+-------+
| 06   | 吴兰   | 1992-01-01 00:00:00 | 女   | 06   | 01   |  31.0 |
+------+--------+---------------------+------+------+------+-------+


1.3 查询存在" 01 "课程但可能不存在" 02 "课程的情况(不存在时显示为 null )

 思路：涉及到表Score，首先找出存在01课程的记为表A，以表A为主表，LEFT JOIN 存在02课程的表B，得出题目查询结果。

SELECT A.SId, A.CId, A.score AS "01课程成绩", B.CId, B.score AS "02课程成绩" FROM 
(SELECT * FROM Score WHERE CId='01') AS A
LEFT JOIN 
(SELECT * FROM Score WHERE CId='02') AS B
ON A.SId=B.SId;

+------+------+----------------+------+----------------+
| SId  | CId  | 01课程成绩     | CId  | 02课程成绩     |
+------+------+----------------+------+----------------+
| 01   | 01   |           80.0 | 02   |           90.0 |
| 02   | 01   |           70.0 | 02   |           60.0 |
| 03   | 01   |           80.0 | 02   |           80.0 |
| 04   | 01   |           50.0 | 02   |           30.0 |
| 05   | 01   |           76.0 | 02   |           87.0 |
| 06   | 01   |           31.0 | NULL |           NULL |
+------+------+----------------+------+----------------+


2. 查询平均成绩大于等于 60 分的同学的学生编号和学生姓名和平均成绩

思路：涉及到表student和表score。首先通过SId把两个表联结(JOIN)起来，然后按SId分组(GROUP BY)，分组后使用AVG函数算出每个学生各个课程的平均成绩，
再使用HAVING过滤出平均成绩>=60分的。需要注意的是题目要查询的包含学生编号和姓名，因此分组的时候把SId和Sname一起放在一起分。

SELECT st.SId, st.Sname, ROUND(AVG(sc.score),2) AS '平均成绩'
FROM Student AS st JOIN Score AS sc ON st.SId=sc.SId 
GROUP BY st.SId,st.Sname HAVING AVG(sc.score)>=60;

+------+--------+--------------+
| SId  | Sname  | 平均成绩     |
+------+--------+--------------+
| 01   | 赵雷   |        89.67 |
| 02   | 钱电   |        70.00 |
| 03   | 孙风   |        80.00 |
| 05   | 周梅   |        81.50 |
| 07   | 郑竹   |        93.50 |
+------+--------+--------------+

2.1 查询所有课程成绩小于 60 分的同学的学生编号和学生姓名和成绩
思路：涉及到表student和表score。成绩小于 60 分，分为两种情况，一种是有成绩且小于60分，另一种是没有成绩(NULL)，比如SId=13的孙七，在score表中不存在，为NULL。

SELECT st.SId , st.Sname, sc.score
FROM Student AS st LEFT JOIN Score AS sc ON st.SId=sc.SId 
WHERE sc.score<60 OR sc.score IS NULL;

+------+--------+-------+
| SId  | Sname  | score |
+------+--------+-------+
| 04   | 李云   |  50.0 |
| 04   | 李云   |  30.0 |
| 04   | 李云   |  20.0 |
| 06   | 吴兰   |  31.0 |
| 06   | 吴兰   |  34.0 |
| 09   | 张三   |  NULL |
| 10   | 李四   |  NULL |
| 11   | 李四   |  NULL |
| 12   | 赵六   |  NULL |
| 13   | 孙七   |  NULL |
+------+--------+-------+


3. 查询在 Score 表存在成绩的学生信息

思路：涉及到表Student和表Score。首先把两张表通过SId关联起来，过滤条件设为Score表中的分数不为空，即存在。

SELECT DISTINCT st.*
FROM Student AS st LEFT JOIN Score AS sc ON st.SId=sc.SId 
WHERE sc.score IS NOT NULL;

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

4、查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩(没成绩的显示为 0 )

思路：涉及到表Student和表Score。首先把两张表通过SId关联起来，以GROUP BY分组，然后count()函数计算选课总数，sum()函数计算总成绩。

SELECT st.SId, st.Sname, COUNT(sc.CId) AS '选课总数', 
SUM(CASE WHEN sc.score IS NULL THEN 0 ELSE sc.score END) AS '课程总成绩'  -- 当没成绩的显示为 0 
FROM Student AS st LEFT JOIN Score AS sc ON st.SId = sc.SId 
GROUP BY st.SId, st.Sname;

+------+--------+--------------+-----------------+
| SId  | Sname  | 选课总数     | 课程总成绩      |
+------+--------+--------------+-----------------+
| 01   | 赵雷   |            3 |           269.0 |
| 02   | 钱电   |            3 |           210.0 |
| 03   | 孙风   |            3 |           240.0 |
| 04   | 李云   |            3 |           100.0 |
| 05   | 周梅   |            2 |           163.0 |
| 06   | 吴兰   |            2 |            65.0 |
| 07   | 郑竹   |            2 |           187.0 |
| 09   | 张三   |            0 |             0.0 |
| 10   | 李四   |            0 |             0.0 |
| 11   | 李四   |            0 |             0.0 |
| 12   | 赵六   |            0 |             0.0 |
| 13   | 孙七   |            0 |             0.0 |
+------+--------+--------------+-----------------+

5、查询"李"姓老师的数量 

思路： 使用谓词Like，%表示0个或多个任意字符，_表示只一个字符。
'李%'表示以李开头的字符串，'%李%’表示中间有李的字符串，'%李'表示结尾是李的字符串，‘_李%’表示第二个字符是李的字符串
谓词：返回值位真值得函数。

SELECT COUNT(TId) FROM Teacher WHERE Tname LIKE '李%';
Course
+----------+
| COUNT(*) |
+----------+
|        1 |
+----------+

6. 查询学过「张三」老师授课的同学的信息

思路：涉及到表Student，表Teacher，表Course，表Score。刚开始的分析过程：
找出选了某个课程编号的学生： Student(SId, Sname) INNER JOIN Score(SId <-- CId) ON SId  
这个课程编号是哪个老师教的： WHERE CId IN
找出张三老师教的课程编号：Course(CId <-- TId) INNER JOINTeacher(TId <-- Tname='张三') ON TId WHERE Tname='张三'

SELECT st.*, sc.CId 
FROM Student AS st LEFT JOIN Score AS sc ON st.SId=sc.SId 
WHERE sc.CId IN(
    SELECT CId 
    FROM Course AS co JOIN Teacher AS te ON co.TId=te.TId 
    WHERE te.Tname='张三'
);

写完发现可以简化，直接把四张表JOIN起来，用一个条件Tname='张三'过滤:
SELECT st.*, sc.CId, te.Tname
FROM Student AS st INNER JOIN Score AS sc ON st.SId=sc.SId
                   INNER JOIN Course AS co ON sc.CId=co.CId
                   INNER JOIN Teacher AS te ON co.TId=te.TId
                   WHERE te.Tname='张三'
                   ORDER BY st.SId;

或者看别人这样写的:
SELECT Student.*, Score.CId, Teacher.Tname FROM Student,Score,Course,Teacher 
WHERE Student.SId=Score.SId 
  AND Score.CId=Course.CId
  AND Course.TId=Teacher.TId
  AND Teacher.Tname='张三';

比我刚想的更容易理解,但是直接将四张表关联起来，如果每张表都超级大，这样写的查找效率就会很低了。
+------+--------+---------------------+------+------+--------+
| SId  | Sname  | Sage                | Ssex | CId  | Tname  |
+------+--------+---------------------+------+------+--------+
| 01   | 赵雷   | 1990-01-01 00:00:00 | 男   | 02   | 张三   |
| 02   | 钱电   | 1990-12-21 00:00:00 | 男   | 02   | 张三   |
| 03   | 孙风   | 1990-12-20 00:00:00 | 男   | 02   | 张三   |
| 04   | 李云   | 1990-12-06 00:00:00 | 男   | 02   | 张三   |
| 05   | 周梅   | 1991-12-01 00:00:00 | 女   | 02   | 张三   |
| 07   | 郑竹   | 1989-01-01 00:00:00 | 女   | 02   | 张三   |
+------+--------+---------------------+------+------+--------+


6.2 查询没学过「张三」老师授课的同学的信息
思路：将Score,Course,Teacher三张表关联起来，找出学过张三老师的课程的所有学生的SId，
那么没有学过张三老师的学生SId就NOT IN (学过张三老师的课程的所有学生的SId)

SELECT st.*
FROM Student AS st
WHERE st.SId NOT IN
(SELECT sc.SId 
FROM Score AS sc INNER JOIN Course AS co ON sc.CId=co.CId
                 INNER JOIN Teacher AS te ON co.TId=te.TId
WHERE Tname = '张三'
);
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

6.3 查询没有学全所有课程的同学的信息

思路：先在Course表中查出课程总数记为max_c，然后在score表中把学生按学号SId分组，查每个学生学习的课程总数记为stu_c，
那么没有学全所有课程的同学stu_c<课程总数max_c，把这个当做HAVING条件过滤出符合题目要求的学生信息。
SELECT st.SId,st.Sname
FROM Student AS st, Score AS sc 
WHERE st.SId=sc.SId
GROUP BY SId, Sname
HAVING COUNT(sc.CId) < (SELECT COUNT(DISTINCT CId) FROM Course);

+------+--------+
| SId  | Sname  |
+------+--------+
| 05   | 周梅   |
| 06   | 吴兰   |
| 07   | 郑竹   |
+------+--------+

但是这样还不对，因为在student表中还有几个学生完全没有选课，即CId为NULL，这样写选不出来这些同学。
转换思路，可以在Score表中查出学全所有课程的同学，最后没有学全的学生SId NOT IN (学全所有课程的同学SId)：
SELECT * FROM Student 
WHERE SId NOT IN (
SELECT SId FROM Score AS sc 
GROUP BY SId 
HAVING COUNT(*) = (SELECT COUNT(DISTINCT CId) FROM Course)
);

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

7、

查询学过编号为"01"但是没有学过编号为"02"的课程的同学的信息
SELECT * 
FROM Student AS st JOIN Score AS sc ON st.SId=sc.SId 
WHERE sc.CId='01' AND sc.SId NOT IN (SELECT SId FROM Score WHERE CId='02');
+------+--------+---------------------+------+------+------+-------+
| SId  | Sname  | Sage                | Ssex | SId  | CId  | score |
+------+--------+---------------------+------+------+------+-------+
| 06   | 吴兰   | 1992-01-01 00:00:00 | 女   | 06   | 01   |  31.0 |
+------+--------+---------------------+------+------+------+-------+


8. 查询至少有一门课与学号为"01"的同学所学相同的同学的信息 
思路：先找出学号01学习的课程，至少有一门即：有CId IN (学号01学习的课程),然后去掉学号01自己的，得到其他同学信息。

SELECT DISTINCT Student.* 
FROM Student INNER JOIN Score ON Student.SId = Score.SId
WHERE Score.CId IN (
SELECT CId
FROM Score WHERE SId='01'
) 
AND Student.SId != '01';

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

8.2 查询和学号为"01"的同学学习的课程完全相同的其他同学的信息 
思路：课程完全相同包括数量相同并且课程编号相同，那么有两种思路，
第一种是先查找学号01学习的课程数量，并且找和该课程数量相同的其他同学(去除掉学号01自己)，然后课程数量相同情况下，
假设学号01的课程有1 2 3，那么如果某个学生选的不是1 2 3（比如1 2 4)，那么就过滤掉该学生。

SELECT * FROM Student 
WHERE SId IN(
SELECT DISTINCT SId FROM Score 
WHERE SId != '01'   -- 把学号为'01'的同学本身过滤掉
GROUP BY SId 
HAVING COUNT(DISTINCT CId) = (SELECT COUNT(DISTINCT CId) FROM Score WHERE SId='01')  -- 首先保证学习的课程数量相等，
)  
AND SId NOT IN(  -- 那么就不要这个学生，这样可以保证课程数量相等后，课程编号CId也相同
SELECT DISTINCT SId FROM Score            -- 如果某学生和01学生的课程数量相等，但是他选的不是1 2 3这三门课
WHERE CId NOT IN(
SELECT CId FROM Score WHERE SId='01'      -- 01学号的学生选的课程假设有 1 2 3
));

+------+--------+---------------------+------+
| SId  | Sname  | Sage                | Ssex |
+------+--------+---------------------+------+
| 02   | 钱电   | 1990-12-21 00:00:00 | 男   |
| 03   | 孙风   | 1990-12-20 00:00:00 | 男   |
| 04   | 李云   | 1990-12-06 00:00:00 | 男   |
+------+--------+---------------------+------+


第二种思路：可以先查找学号01学习了哪些课程(比如学了1 2 3)，
然后找这样的学生：他们学习的课程和学号01学习的课程有相同的(比如学号02学了1 2 3，学号03学了1 3， 学号04学了1)，注意把学号01自身过滤掉
最后，有相同的课程，但是课程数量可能不一样，因此还需要以课程数量相同作为进一步的筛选条件，得出数量相同并且课程编号相同的学生。

SELECT Student.SId 
FROM Student JOIN Score ON Student.SId = Score.SId 
WHERE Score.CId IN   -- 找某些学生学习的课程和学号01学习的课程有相同的
(SELECT CId FROM Score WHERE SId='01') 
AND Score.SId != '01'   --  把学号为'01'的同学本身过滤掉
GROUP BY Student.SId 
HAVING COUNT(Score.CId) = (SELECT COUNT(Score.CId) FROM Score WHERE Score.SId='01');  -- 最后保证学习的课程数量相等
+------+
| SId  |
+------+
| 02   |
| 03   |
| 04   |
+------+

9 查询课程编号为“02”的总成绩
思路：选出编CId为02的课程，把分数score用SUM()函数相加

SELECT SUM(score)
FROM Score WHERE CId='02';
+------------+
| SUM(score) |
+------------+
|      436.0 |
+------------+

 
12. 检索" 01 "课程分数小于 60，按分数降序排列的学生信息
思路：把Student表和Score表联结起来，以CId=01 AND score<60为条件过滤出学生信息，降序用DESC
SELECT st.*, sc.score 
FROM Student AS st INNER JOIN Score AS sc ON st.SId=sc.SId
WHERE sc.CId = '01' AND sc.score < 60 
ORDER BY sc.score DESC;
+------+--------+---------------------+------+-------+
| SId  | Sname  | Sage                | Ssex | score |
+------+--------+---------------------+------+-------+
| 04   | 李云   | 1990-12-06 00:00:00 | 男   |  50.0 |
| 06   | 吴兰   | 1992-01-01 00:00:00 | 女   |  31.0 |
+------+--------+---------------------+------+-------+

13 检索所有课程分数小于 60，按分数降序排列的学生信息
注意：所有课程分数小于60的理解：某个学生选了n门课，这n门课全部都小于60分。并不是说有一门课小于60分的。
刚开始是这样写的：
SELECT * FROM Student WHERE SId IN (
SELECT SId
FROM Score
WHERE score < 60
GROUP BY SId
);
+------+--------+---------------------+------+
| SId  | Sname  | Sage                | Ssex |
+------+--------+---------------------+------+
| 04   | 李云   | 1990-12-06 00:00:00 | 男   |
| 06   | 吴兰   | 1992-01-01 00:00:00 | 女   |
+------+--------+---------------------+------+
得出了04和06，但是这样写如果06的选课和分数变为：
| 06   | 01   |  31.0 |
| 06   | 03   |  34.0 |
| 06   | 04   |  99.0 |
那么按照题目要求是不应该选出06的，因此这个是错误的，这个sql语句是用于选出有一门课小于60分的。
正确的思路：所有课程分数小于60：找出每个学生选课的课程数，再找出该学生小于60分的课程数，这两个课程数量应该相等,再取学生信息和分数降序排。

第一步：找出每个学生选课的课程数：
SELECT SId,COUNT(CId) AS C_cnt  -- 找出每个学生选课的课程数
FROM Score
GROUP BY SId;
得到：
+------+-------+
| SId  | C_cnt |
+------+-------+
| 01   |     3 |
| 02   |     3 |
| 03   |     3 |
| 04   |     3 |
| 05   |     2 |
| 06   |     2 |
| 07   |     2 |
+------+-------+
第二步： 找出每个学生小于60分的课程数：
SELECT SId, COUNT(CId) AS C_cnt -- 找出每个学生小于60分的课程数
FROM Score WHERE score<60
GROUP BY SId;
+------+-------+
| SId  | C_cnt |
+------+-------+
| 04   |     3 |
| 06   |     2 |
+------+-------+
第三步，把这两个表关联起来，并以两种课程数量相等为过滤条件，这样就找出了所有课程都小于60分的学生的学号SId
SELECT * FROM 
(SELECT SId,COUNT(CId) AS C_cnt  -- 找出每个学生选课的课程数
FROM Score
GROUP BY SId) AS A 
INNER JOIN 
(SELECT SId, COUNT(CId) AS C_cnt  -- 找出每个学生小于60分的课程数
FROM Score WHERE score<60
GROUP BY SId) AS B 
ON A.SId=B.SId
WHERE A.C_cnt = B.C_cnt;
+------+-------+------+-------+
| SId  | C_cnt | SId  | C_cnt |
+------+-------+------+-------+
| 04   |     3 | 04   |     3 |
| 06   |     2 | 06   |     2 |
+------+-------+------+-------+
第四步，根据找出的SId，提取出学生的信息和成绩，按降序排列：
SELECT st.*, sc.score 
FROM Student AS st INNER JOIN Score AS sc ON st.SId=sc.SId  -- 学生表和分数表关联
WHERE sc.SId IN(  -- 找出符合条件的SId
	  SELECT A.SId FROM (SELECT SId, COUNT(CId) AS C_cnt FROM Score GROUP BY SId) AS A -- 找出每个学生选课的课程数
					     INNER JOIN 
	                     (SELECT SId, COUNT(CId) AS C_cnt FROM Score WHERE score<60 GROUP BY SId) AS B -- 找出小于60分的课程数
	                     ON A.SId=B.SId
	                     WHERE A.C_cnt = B.C_cnt
)
ORDER BY sc.score DESC;
+------+--------+---------------------+------+-------+
| SId  | Sname  | Sage                | Ssex | score |
+------+--------+---------------------+------+-------+
| 04   | 李云   | 1990-12-06 00:00:00 | 男   |  50.0 |
| 06   | 吴兰   | 1992-01-01 00:00:00 | 女   |  34.0 |
| 06   | 吴兰   | 1992-01-01 00:00:00 | 女   |  31.0 |
| 04   | 李云   | 1990-12-06 00:00:00 | 男   |  30.0 |
| 04   | 李云   | 1990-12-06 00:00:00 | 男   |  20.0 |
+------+--------+---------------------+------+-------+


11. 查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩
 思路： 通过GROUP BY找出每个学生小于60分的课程数量,再用HAVING过滤出两门及两门以上的，得到符合条件的SId,
       再通过得到的SId找出该学生的姓名，在求其平均成绩时，还需要再次使用GROUP BY把每个学生的各科成绩求平均值。
SELECT st.SId, st.Sname, ROUND(AVG(sc.score),2) AS score_avg
FROM Student AS st INNER JOIN Score AS sc ON st.SId=sc.SId 
WHERE st.SId IN (
	SELECT SId
	FROM Score WHERE score<60
	GROUP BY SId
	HAVING COUNT(CId) >= 2
)
GROUP BY st.SId, st.Sname;
+------+--------+-----------+
| SId  | Sname  | score_avg |
+------+--------+-----------+
| 04   | 李云   |     33.33 |
| 06   | 吴兰   |     32.50 |
+------+--------+-----------+


13. 按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩
-- 在使用GROUP BY 分组以后，统计函数是可以出现在SELECT语句中的，
-- 对于学号01的分组，课程编号为01的课程，只有一条成绩，因此max，sum这些函数都是可以的

SELECT SId, 
MAX(CASE WHEN Score.CId='01' THEN Score.score ELSE NULL END) AS score_01,
MAX(CASE WHEN Score.CId='02' THEN Score.score ELSE NULL END) AS score_02,
MAX(CASE WHEN Score.CId='03' THEN Score.score ELSE NULL END) AS score_03,
AVG(score) AS score_avg
FROM Score
GROUP BY SId
ORDER BY AVG(score) DESC;

+------+----------+----------+----------+-----------+
| SId  | score_01 | score_02 | score_03 | score_avg |
+------+----------+----------+----------+-----------+
| 07   |     NULL |     89.0 |     98.0 |  93.50000 |
| 01   |     80.0 |     90.0 |     99.0 |  89.66667 |
| 05   |     76.0 |     87.0 |     NULL |  81.50000 |
| 03   |     80.0 |     80.0 |     80.0 |  80.00000 |
| 02   |     70.0 |     60.0 |     80.0 |  70.00000 |
| 04   |     50.0 |     30.0 |     20.0 |  33.33333 |
| 06   |     31.0 |     NULL |     34.0 |  32.50000 |
+------+----------+----------+----------+-----------+

14. 查询各科成绩最高分、最低分和平均分：
以如下形式显示：课程 ID，课程 name，最高分，最低分，平均分，及格率，中等率，优良率，优秀率
及格为>=60，中等为：70-80，优良为：80-90，优秀为：>=90
要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列

思路：使用GROUP BY对课程编号分组，分组求各科课程的最高分max，最低分min，平均分avg
求及格率： 及格总人数/该课程总人数，使用CASE WHEN 条件(score>=60) THEN 1 ELSE 0 END，当及格时人数加1，然后求和得出该课及格总人数，再用及格总人数/该课程总人数
中等率，优良率，优秀率类似
小数转换为保留两位小数的百分数： concat(truncate(小数*100, 2), '%')

SELECT sc.CId AS '课程ID', co.Cname AS '课程名称', COUNT(sc.CId) AS '选修人数', 
MAX(sc.score) AS '最高分', MIN(sc.score) AS '最低分', ROUND(AVG(sc.score),2) AS '平均分',
( concat(truncate(SUM(CASE WHEN score >= 60 THEN 1 ELSE 0 END) / COUNT(sc.score) * 100, 2), '%')) AS '及格率',
( concat(truncate(SUM(CASE WHEN score >= 70 AND score < 80 THEN 1 ELSE 0 END) / COUNT(sc.score) * 100, 2), '%') ) AS '中等率',
( concat(truncate(SUM(CASE WHEN score >= 80 AND score < 90 THEN 1 ELSE 0 END) / COUNT(sc.score) * 100, 2), '%') ) AS '优良率',
( concat(truncate(SUM(CASE WHEN score >= 90 THEN 1 ELSE 0 END) / COUNT(sc.score) * 100, 2), '%')) AS '优秀率'
FROM Score AS sc JOIN Course AS co ON sc.CId = co.CId
GROUP BY sc.CId, co.Cname
ORDER BY COUNT(sc.CId) DESC, sc.CId;

+----------+--------------+--------------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
| 课程ID   | 课程名称     | 选修人数     | 最高分    | 最低分    | 平均分    | 及格率    | 中等率    | 优良率    | 优秀率    |
+----------+--------------+--------------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
| 01       | 语文         |            6 |      80.0 |      31.0 |     64.50 | 66.66%    | 33.33%    | 33.33%    | 0.00%     |
| 02       | 数学         |            6 |      90.0 |      30.0 |     72.67 | 83.33%    | 0.00%     | 50.00%    | 16.66%    |
| 03       | 英语         |            6 |      99.0 |      20.0 |     68.50 | 66.66%    | 0.00%     | 33.33%    | 33.33%    |
+----------+--------------+--------------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+

15按各科成绩进行排序，并显示排名，总分重复时保留名次空缺
思路：使用窗口函数，将表以窗口为单位分割，并在其中进行排序，求和等操作。
语法为： <窗口函数> over (parition by 分组列 order by 排序列) ，排序用的窗口函数有：rank(), dense_rank(), row_number()
row_number: 1234  rank:1224  dense_rank: 1223

SELECT SId, CId, score, rank () over (partition BY CId ORDER BY score DESC) AS '排名'
FROM Score;
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

15.2 按各科成绩进行排序，并显示排名， 总分重复时合并名次

SELECT SId, CId, score, dense_rank () over (partition BY CId ORDER BY score DESC) AS '排名'
FROM Score;
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

16：查询学生的总成绩，并进行排名，总分重复时保留名次空缺
思路：先对学生分组，然后计算每个学生总分，再用窗口函数排名，order by是依据总分排名： order by sum(score)
SELECT SId, SUM(score) AS '总分', rank() OVER (ORDER BY SUM(score) DESC) AS '总分排名'
FROM Score
GROUP BY SId;
+------+--------+--------------+
| SId  | 总分   | 总分排名     |
+------+--------+--------------+
| 01   |  269.0 |            1 |
| 03   |  240.0 |            2 |
| 02   |  210.0 |            3 |
| 07   |  187.0 |            4 |
| 05   |  163.0 |            5 |
| 04   |  100.0 |            6 |
| 06   |   65.0 |            7 |
+------+--------+--------------+

16.2 查询学生的平均成绩，并进行排名
SELECT SId, AVG(score) AS '平均成绩', rank() OVER (order by AVG(score) DESC) AS '平均成绩排名'
FROM Score
GROUP BY SId;
+------+--------------+--------------------+
| SId  | 平均成绩     | 平均成绩排名       |
+------+--------------+--------------------+
| 07   |     93.50000 |                  1 |
| 01   |     89.66667 |                  2 |
| 05   |     81.50000 |                  3 |
| 03   |     80.00000 |                  4 |
| 02   |     70.00000 |                  5 |
| 04   |     33.33333 |                  6 |
| 06   |     32.50000 |                  7 |
+------+--------------+--------------------+


17 统计各科成绩各分数段的人数：课程编号，课程名称，[100-85],[85-70],[70-60],[60-0]及所占百分比
思路：将Score表和Course表联结起来，用GROUP BY把各科分组，然后COUNT()计算各科选课人数，用CASE WHEN计算各个分数段人数，最后将小数转换为百分比。
SELECT sc.CId, co.Cname, COUNT(sc.SId) AS '选课人数', 
( concat(truncate(SUM(CASE WHEN sc.score >85 AND sc.score <= 100 THEN 1 ELSE 0 END) / COUNT(sc.SId) * 100, 2), '%') ) AS '[100-85]分数段占比',
( concat(truncate(SUM(CASE WHEN sc.score >70 AND sc.score <= 85  THEN 1 ELSE 0 END) / COUNT(sc.SId) * 100, 2), '%') ) AS '[85-70]分数段占比',
( concat(truncate(SUM(CASE WHEN sc.score >60 AND sc.score <= 70  THEN 1 ELSE 0 END) / COUNT(sc.SId) * 100, 2), '%') ) AS '[60-70]分数段占比',
( concat(truncate(SUM(CASE WHEN sc.score >=0 AND sc.score <= 60  THEN 1 ELSE 0 END) / COUNT(sc.SId) * 100, 2), '%') ) AS '[0-60]分数段占比'
FROM Score AS sc INNER JOIN Course AS co ON sc.CId = co.CId
GROUP BY sc.CId, co.Cname;

+------+--------+--------------+-------------------------+------------------------+------------------------+-----------------------+
| CId  | Cname  | 选课人数     | [100-85]分数段占比      | [85-70]分数段占比      | [60-70]分数段占比      | [0-60]分数段占比      |
+------+--------+--------------+-------------------------+------------------------+------------------------+-----------------------+
| 01   | 语文   |            6 | 0.00%                   | 50.00%                 | 16.66%                 | 33.33%                |
| 02   | 数学   |            6 | 50.00%                  | 16.66%                 | 0.00%                  | 33.33%                |
| 03   | 英语   |            6 | 33.33%                  | 33.33%                 | 0.00%                  | 33.33%                |
+------+--------+--------------+-------------------------+------------------------+------------------------+-----------------------+

查询各科成绩前三名的记录
查询所有课程的成绩第2名到第3名的学生信息及该课程成绩

查询每门课选修的学生人数
SELECT CId AS '课程编号', COUNT(SId) AS '选修人数'
FROM Score
GROUP BY CId;
+--------------+--------------+
| 课程编号     | 选修人数     |
+--------------+--------------+
| 01           |            6 |
| 02           |            6 |
| 03           |            6 |
+--------------+--------------+

查询出只修两门课程的学生学号和姓名
SELECT st.SId, st.Sname
FROM Student AS st INNER JOIN Score AS sc ON st.SId = sc.SId
GROUP BY st.SId, st.Sname
HAVING COUNT(sc.CId) = 2;
+------+--------+
| SId  | Sname  |
+------+--------+
| 05   | 周梅   |
| 06   | 吴兰   |
| 07   | 郑竹   |
+------+--------+

查询男生、女生人数
SELECT Ssex AS '性别', COUNT(*) AS '人数'
FROM Student
GROUP BY Ssex;
+--------+--------+
| 性别   | 人数   |
+--------+--------+
| 男     |      4 |
| 女     |      8 |
+--------+--------+

查询名字中含有「风」字的学生信息
SELECT *
FROM Student
WHERE Sname LIKE '%风%';
+------+--------+---------------------+------+
| SId  | Sname  | Sage                | Ssex |
+------+--------+---------------------+------+
| 03   | 孙风   | 1990-12-20 00:00:00 | 男   |
+------+--------+---------------------+------+


查询同名学生名单，并统计同名人数
思路： 使用GROUP BY对姓名分组，如果有同名的，则该分组中名字的数量一定大于1，以此为分组过滤条件筛选。
SELECT Sname, COUNT(*) AS '同名人数'
FROM Student
GROUP BY Sname
HAVING COUNT(Sname) > 1;
+--------+--------------+
| Sname  | 同名人数     |
+--------+--------------+
| 李四   |            2 |
+--------+--------------+



查询 1990 年出生的学生名单
思路： Year()函数可以提取出年份
SELECT * FROM Student WHERE YEAR(Sage) = 1990;
+------+--------+---------------------+------+
| SId  | Sname  | Sage                | Ssex |
+------+--------+---------------------+------+
| 01   | 赵雷   | 1990-01-01 00:00:00 | 男   |
| 02   | 钱电   | 1990-12-21 00:00:00 | 男   |
| 03   | 孙风   | 1990-12-20 00:00:00 | 男   |
| 04   | 李云   | 1990-12-06 00:00:00 | 男   |
+------+--------+---------------------+------+

-- 查询各科成绩前三名的记录 
思路： 把Student表和Score表用SId联结起来，使用row_number为窗口函数，以课程编号CId为分组列的窗口，以分数为排序列，
对于联结后的表排序后得到各科成绩的所有排名，记为allrank表。
然后将allrank表作为子查询，SELECT * FROM allrank WHERE 排名 IN (1,2,3)，得到各科前三名的记录。
如果要查询的是第2名和第3名，同理：SELECT * FROM allrank WHERE 排名 IN (2,3）

注意要给子查询的结果起一个别名，否则会报错误：Error Code: 1248. Every derived table must have its own alias 
原因：嵌套查询的时候子查询出来的的结果是作为一个派生表来进行上一级的查询的，所以子查询的结果必须要有一个别名
SELECT * FROM (
SELECT st.*, sc.CId, sc.score, 
row_number() over (partition BY sc.CId ORDER BY sc.score DESC) AS 排名
FROM Score AS sc INNER JOIN Student AS st ON sc.SId = st.SId
) as allrank
WHERE 排名 IN (1,2,3);
+------+--------+---------------------+------+------+-------+--------+
| SId  | Sname  | Sage                | Ssex | CId  | score | 排名   |
+------+--------+---------------------+------+------+-------+--------+
| 01   | 赵雷   | 1990-01-01 00:00:00 | 男   | 01   |  80.0 |      1 |
| 03   | 孙风   | 1990-12-20 00:00:00 | 男   | 01   |  80.0 |      2 |
| 05   | 周梅   | 1991-12-01 00:00:00 | 女   | 01   |  76.0 |      3 |
| 01   | 赵雷   | 1990-01-01 00:00:00 | 男   | 02   |  90.0 |      1 |
| 07   | 郑竹   | 1989-01-01 00:00:00 | 女   | 02   |  89.0 |      2 |
| 05   | 周梅   | 1991-12-01 00:00:00 | 女   | 02   |  87.0 |      3 |
| 01   | 赵雷   | 1990-01-01 00:00:00 | 男   | 03   |  99.0 |      1 |
| 07   | 郑竹   | 1989-01-01 00:00:00 | 女   | 03   |  98.0 |      2 |
| 02   | 钱电   | 1990-12-21 00:00:00 | 男   | 03   |  80.0 |      3 |
+------+--------+---------------------+------+------+-------+--------+

SELECT * FROM (
SELECT st.*, sc.CId, sc.score, row_number() over (partition BY sc.CId ORDER BY sc.score DESC) AS 排名
FROM Score AS sc INNER JOIN Student AS st ON sc.SId = st.SId
) as allrank
WHERE 排名 IN (2,3);
+------+--------+---------------------+------+------+-------+--------+
| SId  | Sname  | Sage                | Ssex | CId  | score | 排名   |
+------+--------+---------------------+------+------+-------+--------+
| 03   | 孙风   | 1990-12-20 00:00:00 | 男   | 01   |  80.0 |      2 |
| 05   | 周梅   | 1991-12-01 00:00:00 | 女   | 01   |  76.0 |      3 |
| 07   | 郑竹   | 1989-01-01 00:00:00 | 女   | 02   |  89.0 |      2 |
| 05   | 周梅   | 1991-12-01 00:00:00 | 女   | 02   |  87.0 |      3 |
| 07   | 郑竹   | 1989-01-01 00:00:00 | 女   | 03   |  98.0 |      2 |
| 02   | 钱电   | 1990-12-21 00:00:00 | 男   | 03   |  80.0 |      3 |
+------+--------+---------------------+------+------+-------+--------+

查询平均成绩大于等于 85 的所有学生的学号、姓名和平均成绩
SELECT st.SId, st.Sname, AVG(sc.score)
FROM Student AS st INNER JOIN Score AS sc ON st.SId = sc.SId
GROUP BY st.SId,st.Sname
HAVING AVG(sc.score) > 85;
+------+--------+---------------+
| SId  | Sname  | AVG(sc.score) |
+------+--------+---------------+
| 01   | 赵雷   |      89.66667 |
| 07   | 郑竹   |      93.50000 |
+------+--------+---------------+

查询课程名称为「数学」，且分数低于 60 的学生姓名和分数
SELECT st.SId, st.Sname, sc.score
FROM Student AS st INNER JOIN Score AS sc ON st.SId = sc.SId
                   INNER JOIN Course AS co ON sc.CId = co.CId
WHERE co.Cname = '数学' AND sc.score < 60;
+------+--------+-------+
| SId  | Sname  | score |
+------+--------+-------+
| 04   | 李云   |  30.0 |
+------+--------+-------+

查询所有学生的课程及分数情况（存在学生没成绩，没选课的情况）
简略版的：
SELECT st.SId, st.Sname, sc.CId, sc.score
FROM Student AS st LEFT JOIN Score AS sc ON st.SId = sc.SId
ORDER BY st.SId, sc.CId;
+------+--------+------+-------+
| SId  | Sname  | CId  | score |
+------+--------+------+-------+
| 01   | 赵雷   | 01   |  80.0 |
| 01   | 赵雷   | 02   |  90.0 |
| 01   | 赵雷   | 03   |  99.0 |
| 02   | 钱电   | 01   |  70.0 |
| 02   | 钱电   | 02   |  60.0 |
| 02   | 钱电   | 03   |  80.0 |
| 03   | 孙风   | 01   |  80.0 |
| 03   | 孙风   | 02   |  80.0 |
| 03   | 孙风   | 03   |  80.0 |
| 04   | 李云   | 01   |  50.0 |
| 04   | 李云   | 02   |  30.0 |
| 04   | 李云   | 03   |  20.0 |
| 05   | 周梅   | 01   |  76.0 |
| 05   | 周梅   | 02   |  87.0 |
| 06   | 吴兰   | 01   |  31.0 |
| 06   | 吴兰   | 03   |  34.0 |
| 07   | 郑竹   | 02   |  89.0 |
| 07   | 郑竹   | 03   |  98.0 |
| 09   | 张三   | NULL |  NULL |
| 10   | 李四   | NULL |  NULL |
| 11   | 李四   | NULL |  NULL |
| 12   | 赵六   | NULL |  NULL |
| 13   | 孙七   | NULL |  NULL |
+------+--------+------+-------+
完善版：
SELECT st.SId, st.Sname,
SUM(CASE WHEN co.Cname='语文' THEN sc.score ELSE NULL END) AS '语文成绩',
SUM(CASE WHEN co.Cname='数学' THEN sc.score ELSE NULL END) AS '数学成绩',
SUM(CASE WHEN co.Cname='英语' THEN sc.score ELSE NULL END) AS '英语成绩',
SUM(sc.score) AS '总分'
FROM Student AS st LEFT JOIN Score AS sc ON st.SId = sc.SId
                   LEFT JOIN Course AS co ON sc.CId = co.CId
GROUP BY st.SId, st.Sname;
+------+--------+--------------+--------------+--------------+--------+
| SId  | Sname  | 语文成绩     | 数学成绩     | 英语成绩     | 总分   |
+------+--------+--------------+--------------+--------------+--------+
| 01   | 赵雷   |         80.0 |         90.0 |         99.0 |  269.0 |
| 02   | 钱电   |         70.0 |         60.0 |         80.0 |  210.0 |
| 03   | 孙风   |         80.0 |         80.0 |         80.0 |  240.0 |
| 04   | 李云   |         50.0 |         30.0 |         20.0 |  100.0 |
| 05   | 周梅   |         76.0 |         87.0 |         NULL |  163.0 |
| 06   | 吴兰   |         31.0 |         NULL |         34.0 |   65.0 |
| 07   | 郑竹   |         NULL |         89.0 |         98.0 |  187.0 |
| 09   | 张三   |         NULL |         NULL |         NULL |   NULL |
| 10   | 李四   |         NULL |         NULL |         NULL |   NULL |
| 11   | 李四   |         NULL |         NULL |         NULL |   NULL |
| 12   | 赵六   |         NULL |         NULL |         NULL |   NULL |
| 13   | 孙七   |         NULL |         NULL |         NULL |   NULL |
+------+--------+--------------+--------------+--------------+--------+


查询不同老师所教不同课程平均分从高到低显示
思路：以课程为主体，将Score表, Couser表，Teacher表联结起来，通过课程编号分组，求不同课程的平均分。
SELECT sc.CId, co.Cname, te.Tname, ROUND(AVG(sc.score),2) AS score_avg
FROM Score AS sc INNER JOIN Course AS co ON sc.CId = co.CId
				 INNER JOIN Teacher AS te ON co.TId = te.TId
GROUP BY sc.CId, co.Cname, te.Tname
ORDER BY score_avg DESC;
+------+--------+--------+-----------+
| CId  | Cname  | Tname  | score_avg |
+------+--------+--------+-----------+
| 02   | 数学   | 张三   |     72.67 |
| 03   | 英语   | 王五   |     68.50 |
| 01   | 语文   | 李四   |     64.50 |
+------+--------+--------+-----------+


查询任何一门课程成绩在 70 分以上的姓名、课程名称和分数
SELECT st.Sname, co.Cname, sc.score
FROM Student AS st INNER JOIN Score AS sc ON st.SId = sc.SId
                   INNER JOIN Course AS co ON sc.CId = co.CId
WHERE sc.score > 70
ORDER BY st.SId;
+--------+--------+-------+
| Sname  | Cname  | score |
+--------+--------+-------+
| 赵雷   | 语文   |  80.0 |
| 赵雷   | 数学   |  90.0 |
| 赵雷   | 英语   |  99.0 |
| 钱电   | 英语   |  80.0 |
| 孙风   | 数学   |  80.0 |
| 孙风   | 英语   |  80.0 |
| 孙风   | 语文   |  80.0 |
| 周梅   | 语文   |  76.0 |
| 周梅   | 数学   |  87.0 |
| 郑竹   | 数学   |  89.0 |
| 郑竹   | 英语   |  98.0 |
+--------+--------+-------+

查询不及格的课程并按课程号从大到小排列
SELECT sc.SId, sc.CId, co.Cname, sc.score
FROM Score AS sc LEFT JOIN Course AS co ON sc.CId = co.CId
WHERE sc.score<60
ORDER BY sc.CId;
+------+------+--------+-------+
| SId  | CId  | Cname  | score |
+------+------+--------+-------+
| 04   | 01   | 语文   |  50.0 |
| 06   | 01   | 语文   |  31.0 |
| 04   | 02   | 数学   |  30.0 |
| 04   | 03   | 英语   |  20.0 |
| 06   | 03   | 英语   |  34.0 |
+------+------+--------+-------+

查询课程编号为 01 且课程成绩在 80 分以上的学生的学号和姓名
SELECT st.SId, st.Sname
FROM Score AS sc LEFT JOIN Student AS st ON st.SId = sc.SId
WHERE sc.CId = '01' AND sc.score > 80;
结果：
Empty set (0.00 sec)

求每门课程的学生人数
SELECT CId, COUNT(SId) AS '学生人数'
FROM Score
GROUP BY CId
+------+--------------+
| CId  | 学生人数     |
+------+--------------+
| 01   |            6 |
| 02   |            6 |
| 03   |            6 |
+------+--------------+

成绩不重复，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩
成绩有重复的情况下，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩
查询不同课程成绩相同的学生的学生编号、课程编号、学生成绩
查询每门功成绩最好的前两名
统计每门课程的学生选修人数（超过5人的课程才统计）。要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列（不重要）
检索至少选修两门课程的学生学号
查询选修了全部课程的学生信息
查询没学过“张三”老师讲授的任一门课程的学生姓名
查询两门以上不及格课程的同学的学号及其平均成绩

查询各学生的年龄，只按年份来算,（精确到月份）

查询本周过生日的学生
查询下周过生日的学生
查询本月过生日的学生
查询下月过生日的学生



*/












