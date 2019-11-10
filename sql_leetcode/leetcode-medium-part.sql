

本文包含LeetCode中medium难度部分的SQL练习题的解题思路和通过代码，关于题目描述可以查看[leetcode原网站](https://leetcode.com/problemset/database/)，或者[leetcode中文网站](https://leetcode-cn.com/problemset/database/?difficulty=%E4%B8%AD%E7%AD%89)

关于带锁的部分练习，由于博主没有开会员，所以没有在LeetCode网站上测试过，参考了别的博客写的。

Easy部分的练习题：[点击这里](https://huanyouchen.github.io/2019/09/11/SQL-exercises-in-LeetCode-easy-part/)

<!--more-->

### 177. Nth Highest Salary 第N高的薪水

题目描述：https://leetcode.com/problems/nth-highest-salary/

解题思路：和取第二高的思路相同。先把相同薪水的都去重，然后逆序排序，使用LIMIT取第n高的薪水。

通过代码：
```sql
CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
SET N=N-1;
  RETURN (
      # Write your MySQL query statement below.
      SELECT DISTINCT Salary FROM Employee ORDER BY Salary DESC LIMIT N, 1
  );
END
```
这里`SET N=N-1`的意思是从第1个位置开始，往后取排在第N-1位置的薪水。比如取第2高的，则`LIMIT 1(N=2-1),1`，取第5高的，则`LIMIT 4(N=5-1),1`


### 178. Rank Scores 分数排名

题目描述：https://leetcode.com/problems/rank-scores/

解题思路：最简单的使用窗口函数dense_rank,在Oracle中可以通过，不过在MySQL中不能。
不用窗口函数实现的思路：
首先需要对分数表去重，统计共有第n个排名
然后把分数表分为两份sa和sb, 对于sa中分数sa.Score，统计去重后的sb表中有比sa.Score大的个数，即是sa.Score的排名。



通过代码：
```sql
# Oracle中
SELECT Score, DENSE_RANK() OVER (ORDER BY Score DESC) AS Rank
FROM Scores

# MySQL
SELECT sa.Score, 
    (    
        # 统计去重后的sb表中有比sa.Score大的个数
        SELECT COUNT(DISTINCT sb.Score)
        FROM Scores AS sb
        WHERE sb.Score >= sa.Score
    ) AS Rank
FROM Scores AS sa
ORDER BY Score DESC;
```

### 180. Consecutive Numbers连续出现的数字

题目描述：https://leetcode.com/problems/consecutive-numbers/

解题思路：找出所有至少连续三次出现的数字，即id是连续至少三次的，且id对应的num是相同的。那么分为两步

首先判断id是连续至少三次的，可以将表自连接三份，如果表1的第n位的id = 表2的第n+1位的id-1，且表2的第n+1位的id=表3的第n+2位的id-1，那么就表示id是连续至少三次的。

然后判断id对应的num是否相同，即表1的第n位的id对应的num = 表2的第n+1位的id对应的num = 表3的第n+2位的id对应的num

代码：
```sql
# Write your MySQL query statement below
SELECT L1.Num AS ConsecutiveNums
FROM Logs AS L1, Logs AS L2, Logs AS L3
WHERE L1.Id = L2.Id-1 
      AND L2.Id = L3.Id-1
      AND L1.Num = L2.Num
      AND L2.Num = L3.Num;

```
结果提示错误，报错原因：
```
Input:
{"headers": {"Logs": ["Id", "Num"]}, "rows": {"Logs": [[1, 3], [2, 3], [3, 3], [4, 3]]}}
Output:
{"headers": ["ConsecutiveNums"], "values": [[3], [3]]}
Expected:
{"headers":["ConsecutiveNums"],"values":[[3]]}

```
可以看出，如果连续出现4个3， 那么会有id为1-2-3的值为3和id为2-3-4的值为3，这两种情况，因此需要对结果去重，通过代码：
```sql
SELECT DISTINCT L1.Num AS ConsecutiveNums
FROM Logs AS L1, Logs AS L2, Logs AS L3
WHERE L1.Id = L2.Id-1 
      AND L2.Id = L3.Id-1
      AND L1.Num = L2.Num
      AND L2.Num = L3.Num;
```

### 184. Department Highest Salary部门工资最高的员工

题目描述：https://leetcode.com/problems/department-highest-salary/

解题思路：要求找出每个部门工资最高的。那么先按部门编号把部门分组，分组后求出每个部门工资最大的，即：
```sql
SELECT DepartmentId, MAX(Salary)
FROM Employee
GROUP BY DepartmentId
```
然后，把部门表和员工表联结，取出需要的信息

通过代码：
```sql
SELECT d.Name AS Department, e.Name AS Employee, e.Salary AS Salary
FROM Employee AS e INNER JOIN Department AS d ON e.DepartmentId = d.Id
WHERE (DepartmentId, Salary) IN (
    SELECT DepartmentId, MAX(Salary)
    FROM Employee 
    GROUP BY DepartmentId
);
```


### 534	Game Play Analysis III 游戏玩法分析 III 

题目描述：
```
Table: Activity

+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| player_id    | int     |
| device_id    | int     |
| event_date   | date    |
| games_played | int     |
+--------------+---------+
(player_id, event_date) is the primary key of this table.
This table shows the activity of players of some game.
Each row is a record of a player who logged in and played a number of games (possibly 0) 
before logging out on some day using some device.


Write an SQL query that reports for each player and date, how many games played so far by the player.
That is, the total number of games played by the player until that date. Check the example for clarity.

The query result format is in the following example:

Activity table:
+-----------+-----------+------------+--------------+
| player_id | device_id | event_date | games_played |
+-----------+-----------+------------+--------------+
| 1         | 2         | 2016-03-01 | 5            |
| 1         | 2         | 2016-05-02 | 6            |
| 1         | 3         | 2017-06-25 | 1            |
| 3         | 1         | 2016-03-02 | 0            |
| 3         | 4         | 2018-07-03 | 5            |
+-----------+-----------+------------+--------------+

Result table:
+-----------+------------+---------------------+
| player_id | event_date | games_played_so_far |
+-----------+------------+---------------------+
| 1         | 2016-03-01 | 5                   |
| 1         | 2016-05-02 | 11                  |
| 1         | 2017-06-25 | 12                  |
| 3         | 2016-03-02 | 0                   |
| 3         | 2018-07-03 | 5                   |
+-----------+------------+---------------------+
For the player with id 1, 5 + 6 = 11 games played by 2016-05-02, and 5 + 6 + 1 = 12 games played by 2017-06-25.
For the player with id 3, 0 + 5 = 5 games played by 2018-07-03.
Note that for each player we only care about the days when the player logged in.

```
解题思路：累加和问题，题目要求出每个玩家在某个时期之前玩过的游戏个数累加和。
那么先找出某个日期之前的所有信息：
```sql
SELECT *
FROM Activity AS A1 INNER JOIN Activity AS A2
ON (A1.player_id = A2.player_id AND A1.event_date <= A2.event_date)
```
再把玩家和该玩家在某个时期分组，求游戏个数之和。
通过代码：
```sql
SELECT A2.player_id, A2.event_date, SUM(A1.games_played) AS games_played_so_far
FROM Activity AS A1 INNER JOIN Activity AS A2 
ON (A1.player_id = A2.player_id AND A1.event_date <= A2.event_date)
GROUP BY A2.player_id, A2.event_date;
```

### 550	Game Play Analysis IV 游戏玩法分析 IV

题目描述：	
```
Table: Activity

+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| player_id    | int     |
| device_id    | int     |
| event_date   | date    |
| games_played | int     |
+--------------+---------+
(player_id, event_date) is the primary key of this table.
This table shows the activity of players of some game.
Each row is a record of a player who logged in and played a number of games (possibly 0) before logging out on some day using some device.
 

Write an SQL query that reports the fraction of players that logged in again on the day after the day they first logged in, rounded to 2 decimal places. In other words, you need to count the number of players that logged in for at least two consecutive days starting from their first login date, then divide that number by the total number of players.

The query result format is in the following example:

Activity table:
+-----------+-----------+------------+--------------+
| player_id | device_id | event_date | games_played |
+-----------+-----------+------------+--------------+
| 1         | 2         | 2016-03-01 | 5            |
| 1         | 2         | 2016-03-02 | 6            |
| 2         | 3         | 2017-06-25 | 1            |
| 3         | 1         | 2016-03-02 | 0            |
| 3         | 4         | 2018-07-03 | 5            |
+-----------+-----------+------------+--------------+

Result table:
+-----------+
| fraction  |
+-----------+
| 0.33      |
+-----------+
Only the player with id 1 logged back in after the first day he had logged in so the answer is 1/3 = 0.33

```
题目要求出首次登陆后，第二天又登陆的人数占总人数的比例。
解题思路：

按照玩家id分组，找出每个玩家首次登陆和该玩家第二次登陆的时间，来判断是否连续，如果连续，计数器加1
将计数器得到的总和除以游戏总人数，得到比例，保留两位小数

首先找出每个玩家首次登陆的日期：
```sql
SELECT player_id, MIN(event_date)
FROM Activity
GROUP BY player_id
```

然后排除表中不是玩家首次登陆的记录：
```sql
SELECT *
FROM Activity
WHERE (player_id, event_date) IN (
    SELECT player_id, MIN(event_date)
    FROM Activity
    GROUP BY player_id
)
```

再然后找出首次登陆后，该玩家第二天也登陆了，这里可以把Activity表自连接，B表时间作为A表时间的第二天，用DATEDIFF函数判断相邻一天。

```sql
SELECT *
FROM Activity AS A INNER JOIN Activity AS B
ON A.player_id = B.player_id AND DATEDIFF(B.event_date, A.event_date) = 1
WHERE (A.player_id, A.event_date) IN (
    SELECT player_id, MIN(event_date)
    FROM Activity
    GROUP BY player_id
)
```

最后求出比例，用ROUND函数保留两位小数：
```sql
SELECT ROUND(COUNT(DISTINCT B.event_date) / COUNT(DISTINCT A.player_id), 2) AS fraction
FROM Activity AS A INNER JOIN Activity AS B
ON A.player_id = B.player_id AND DATEDIFF(B.event_date, A.event_date) = 1
WHERE (A.player_id, A.event_date) IN (
    SELECT player_id, MIN(event_date)
    FROM Activity
    GROUP BY player_id
)

```

### 570	Managers with at Least 5 Direct Reports 至少有5名直接下属的经理

题目描述：
```
The Employee table holds all employees including their managers. Every employee has an Id, and there is also a column for the manager Id.

+------+----------+-----------+----------+
|Id    |Name 	  |Department |ManagerId |
+------+----------+-----------+----------+
|101   |John 	  |A 	      |null      |
|102   |Dan 	  |A 	      |101       |
|103   |James 	  |A 	      |101       |
|104   |Amy 	  |A 	      |101       |
|105   |Anne 	  |A 	      |101       |
|106   |Ron 	  |B 	      |101       |
+------+----------+-----------+----------+
Given the Employee table, write a SQL query that finds out managers with at least 5 direct report. For the above table, your SQL query should return:

+-------+
| Name  |
+-------+
| John  |
+-------+
Note:
No one would report to himself.
```

解题思路：求出至少有5个直接下属的经理。将Employee表按照经理id分组，使用HAVING过滤出下属至少5个的经理id，将这个查询结果作为临时表与原表内连接查询Name即可

通过代码：
```sql
SELECT E.Name
FROM Employee AS E 
INNER JOIN (
    SELECT ManagerId
    FROM Employee
    GROUP BY ManagerId
    HAVING COUNT(Id) >= 5
    ) AS M
ON E.Id = M.ManagerId;
```

### 574	Winning Candidate 当选者 

题目描述：
```
Table: Candidate

+-----+---------+
| id  | Name    |
+-----+---------+
| 1   | A       |
| 2   | B       |
| 3   | C       |
| 4   | D       |
| 5   | E       |
+-----+---------+  
Table: Vote

+-----+--------------+
| id  | CandidateId  |
+-----+--------------+
| 1   |     2        |
| 2   |     4        |
| 3   |     3        |
| 4   |     2        |
| 5   |     5        |
+-----+--------------+
id is the auto-increment primary key,
CandidateId is the id appeared in Candidate table.
Write a sql to find the name of the winning candidate, the above example will return the winner B.

+------+
| Name |
+------+
| B    |
+------+
Notes:

You may assume there is no tie, in other words there will be at most one winning candidate.
```

解题思路：把Vote表按CandidateId分组，统计投票的个数，逆序取最高投票的CandidateId，这个id就是Candidate表中的id，对应的就是得票最多的候选人的名字。

通过代码：
```sql
SELECT Name 
FROM Candidate
WHERE id IN (
	SELECT t.CandidateId FROM (
		SELECT CandidateId
		FROM Vote
		GROUP BY CandidateId
		ORDER BY COUNT(*) DESC
		LIMIT 0,1
    ) AS t
);

```
注意IN ()内层的SELECT语句，需要额外嵌套一层，否则会报错：
Error Code: 1235. This version of MySQL doesn't yet support 'LIMIT & IN/ALL/ANY/SOME subquery'

也可以这样写：
```sql
SELECT
FROM Candidate AS C JOIN
(
    SELECT V.CandidateId, COUNT(V.id) AS cnt
    FROM Vote AS V
    GROUP BY CandidateId
    ORDER BY cnt DESC
    LIMIT 0,1
) AS T
ON C.id = T.CandidateId;

```
### 578	Get Highest Answer Rate Question 查询回答率最高的问题 

题目描述：
```
Get the highest answer rate question from a table survey_log with these columns: uid, action, question_id, answer_id, q_num, timestamp.

uid means user id; action has these kind of values: "show", "answer", "skip"; answer_id is not null when action column is "answer", while is null for "show" and "skip"; q_num is the numeral order of the question in current session.

Write a sql query to identify the question which has the highest answer rate.

Example:

Input:
+------+-----------+--------------+------------+-----------+------------+
| uid  | action    | question_id  | answer_id  | q_num     | timestamp  |
+------+-----------+--------------+------------+-----------+------------+
| 5    | show      | 285          | null       | 1         | 123        |
| 5    | answer    | 285          | 124124     | 1         | 124        |
| 5    | show      | 369          | null       | 2         | 125        |
| 5    | skip      | 369          | null       | 2         | 126        |
+------+-----------+--------------+------------+-----------+------------+
Output:
+-------------+
| survey_log  |
+-------------+
|    285      |
+-------------+
Explanation:
question 285 has answer rate 1/1, while question 369 has 0/1 answer rate, so output 285.

Note: The highest answer rate meaning is: answer number's ratio in show number in the same question.
```

解题思路：题目要求出回答率最高的问题。首先，题目中表达的action的三个动作的含义，每个问题都有show，该问题下可以选择回答answer和跳过skip，因此，某个问题的`回答率 = answer的个数 / show的个数`， 然后把问题id分组，每个问题计算其answer的个数，和show的个数，进而得到回答率，将每个问题的回答率逆序排序，取第一个就是最高的回答率

通过代码：
```sql
SELECT question_id AS survey_log
FROM survey_log
GROUP BY question_id
ORDER BY SUM(IF(action='answer', 1, 0)) / SUM(IF(action='show', 1, 0)) DESC
LIMIT 0,1;
```

除了用SUM IF，还可以用CASE WHEN方法
```sql
SELECT question_id AS 'survey_log'
FROM (
    SELECT question_id, 
           SUM(CASE WHEN action='answer' THEN 1 ELSE 0 END) AS num_answer,
           SUM(CASE WHEN action='show' THEN 1 ELSE 0 END) AS num_show
    FROM survey_log
    GROUP BY question_id
    ) AS t
ORDER BY (num_answer / num_show) DESC
LIMIT 0,1

```
### 580	Count Student Number in Departments 统计各专业学生人数

题目描述：

```
A university uses 2 data tables, student and department, to store data about its students and the departments associated with each major.

Write a query to print the respective department name and number of students majoring in each department for all departments in the department table (even ones with no current students).

Sort your results by descending number of students; if two or more departments have the same number of students, then sort those departments alphabetically by department name.

The student is described as follow:

| Column Name  | Type      |
|--------------|-----------|
| student_id   | Integer   |
| student_name | String    |
| gender       | Character |
| dept_id      | Integer   |
where student_id is the student's ID number, student_name is the student's name, gender is their gender, and dept_id is the department ID associated with their declared major.

And the department table is described as below:

| Column Name | Type    |
|-------------|---------|
| dept_id     | Integer |
| dept_name   | String  |
where dept_id is the department's ID number and dept_name is the department name.

Here is an example input:
student table:

| student_id | student_name | gender | dept_id |
|------------|--------------|--------|---------|
| 1          | Jack         | M      | 1       |
| 2          | Jane         | F      | 1       |
| 3          | Mark         | M      | 2       |
department table:

| dept_id | dept_name   |
|---------|-------------|
| 1       | Engineering |
| 2       | Science     |
| 3       | Law         |
The Output should be:

| dept_name   | student_number |
|-------------|----------------|
| Engineering | 2              |
| Science     | 1              |
| Law         | 0              |

```

解题思路：先把部门左连接学生，然后按部门分组，统计每个部门组内的学生，然后按学生数量由高到低排序。

通过代码：
```sql

SELECT D.dept_name, COUNT(S.student_id) AS student_number
FROM department AS D LEFT JOIN student AS S
ON D.dept_id = S.dept_id
GROUP BY D.dept_name
ORDER BY student_number DESC, D.dept_name;

```

### 585	Investments in 2016 2016年的投资

题目描述：
```
Write a query to print the sum of all total investment values in 2016 (TIV_2016), to a scale of 2 decimal places, for all policy holders who meet the following criteria:

Have the same TIV_2015 value as one or more other policyholders.
Are not located in the same city as any other policyholder (i.e.: the (latitude, longitude) attribute pairs must be unique).
Input Format:
The insurance table is described as follows:

| Column Name | Type          |
|-------------|---------------|
| PID         | INTEGER(11)   |
| TIV_2015    | NUMERIC(15,2) |
| TIV_2016    | NUMERIC(15,2) |
| LAT         | NUMERIC(5,2)  |
| LON         | NUMERIC(5,2)  |
where PID is the policyholder's policy ID, TIV_2015 is the total investment value in 2015, TIV_2016 is the total investment value in 2016, LAT is the latitude of the policy holder's city, and LON is the longitude of the policy holder's city.

Sample Input

| PID | TIV_2015 | TIV_2016 | LAT | LON |
|-----|----------|----------|-----|-----|
| 1   | 10       | 5        | 10  | 10  |
| 2   | 20       | 20       | 20  | 20  |
| 3   | 10       | 30       | 20  | 20  |
| 4   | 10       | 40       | 40  | 40  |
Sample Output

| TIV_2016 |
|----------|
| 45.00    |
Explanation

The first record in the table, like the last record, meets both of the two criteria.
The TIV_2015 value '10' is as the same as the third and forth record, and its location unique.

The second record does not meet any of the two criteria. Its TIV_2015 is not like any other policyholders.

And its location is the same with the third record, which makes the third record fail, too.

So, the result is the sum of TIV_2016 of the first and last record, which is 45.

```
解题思路：首先读题都不明白，看别人的翻译后才明白。在2016年投资成功的条件是：
- 和一个或多个投保人有相同的TIV_2015。
- 不和其他投保人在同一城市（就是说（纬度，经度）必须唯一）。

其中，PID是投保人ID，TIV_2015是2015年投资总额，TIV_2016是2016年投资总额，LAT是投保人城市纬度，LON是投保人城市经度。

第一条，在 2015 年的投保额 (TIV_2015) 至少跟一个其他投保人在 2015 年的投保额相同。

```sql
SELECT TIV_2015
FROM insurance
GROUP BY TIV_2015
HAVING COUNT(*) > 1;
```
第二条，（纬度，经度）必须唯一

```sql
SELECT CONCAT(LAT, LON)
FROM insurance
GROUP BY LAT,LON
HAVING COUNT(*) = 1;
```

将符合这两个条件的TIV_2016值加起来，就是2016年的投资

通过代码：
```sql
SELECT SUM(TIV_2016) AS TIV_2016
FROM insurance
WHERE TIV_2015 IN 
    (
        SELECT TIV_2015
        FROM insurance
        GROUP BY TIV_2015
        HAVING COUNT(*) > 1
    )
AND CONCAT(LAT, LON) IN 
    (
        SELECT CONCAT(LAT, LON)
        FROM insurance
        GROUP BY LAT,LON
        HAVING COUNT(*) = 1
    )
;
```

### 602 Friend Requests II: Who Has the Most Friends 好友申请 II ：谁有最多的好友
 
题目描述：
```
In social network like Facebook or Twitter, people send friend requests and accept others' requests as well.

Table request_accepted holds the data of friend acceptance, while requester_id and accepter_id both are the id of a person.
 
| requester_id | accepter_id | accept_date|
|--------------|-------------|------------|
| 1            | 2           | 2016_06-03 |
| 1            | 3           | 2016-06-08 |
| 2            | 3           | 2016-06-08 |
| 3            | 4           | 2016-06-09 |
Write a query to find the the people who has most friends and the most friends number. For the sample data above, the result is:
| id | num |
|----|-----|
| 3  | 3   |
Note:
It is guaranteed there is only 1 people having the most friends.
The friend request could only been accepted once, which mean there is no multiple records with the same requester_id and accepter_id value.

Explanation:
The person with id '3' is a friend of people '1', '2' and '4', so he has 3 friends in total, which is the most number than any others.

Follow-up:
In the real world, multiple people could have the same most number of friends, can you find all these people in this case?

```
题目要求出谁有最多的好友，及他的好友数量。
解题思路：这个题没有思路，看别人写的:

用UNION ALL把请求id和接受id都找出来：
```sql
SELECT requester_id AS id FROM request_accepted
UNION ALL
SELECT accepter_id AS id FROM request_accepted

```
然后按id分组，计算每个id出现的次数：
```sql
SELECT t.id, COUNT(t.id) AS num 
FROM (
        SELECT requester_id AS id FROM request_accepted
        UNION ALL
        SELECT accepter_id AS id FROM request_accepted
    ) AS t
GROUP BY t.id

```
最后，根据出现次数降序排列，第一条就是好友数量最多的：

```sql
SELECT t.id, COUNT(t.id) AS num 
FROM (
        SELECT requester_id AS id FROM request_accepted
        UNION ALL
        SELECT accepter_id AS id FROM request_accepted
    ) AS t
GROUP BY t.id
ORDER BY num DESC
LIMIT 0,1;
```

### 608	Tree Node 树节点 

题目描述：

```
Given a table tree, id is identifier of the tree node and p_id is its parent node id.

+----+------+
| id | p_id |
+----+------+
| 1  | null |
| 2  | 1    |
| 3  | 1    |
| 4  | 2    |
| 5  | 2    |
+----+------+
Each node in the tree can be one of three types:
Leaf: if the node is a leaf node.
Root: if the node is the root of the tree.
Inner: If the node is neither a leaf node nor a root node.

Write a query to print the node id and the type of the node. Sort your output by the node id. The result for the above sample is:

+----+------+
| id | Type |
+----+------+
| 1  | Root |
| 2  | Inner|
| 3  | Leaf |
| 4  | Leaf |
| 5  | Leaf |
+----+------+

Explanation

Node '1' is root node, because its parent node is NULL and it has child node '2' and '3'.
Node '2' is inner node, because it has parent node '1' and child node '4' and '5'.
Node '3', '4' and '5' is Leaf node, because they have parent node and they don't have child node.

And here is the image of the sample tree as below:
 

	      1
	    /   \
           2     3
         /   \
        4     5

Note:
If there is only one node on the tree, you only need to output its root attributes.

```

解题思路：节点类型判断依据：没有父节点的是根Root，没有子节点的是叶Leaf，其他是内部节点Inner

首先找出根节点的：
```sql
SELECT id, 'Root' AS Type
FROM tree
WHERE p_id IS NULL;
```

然后找出叶节点，叶节点有两个条件，一个是它的父节点不空，第二个是它不是父节点：
```sql
SELECT id, 'Leaf' AS Type
FROM tree
WHERE id NOT IN (
    SELECT p_id
    FROM tree
    WHERE p_id IS NOT NULL
);

```
最后找出内部节点，内部节点的条件，一个是它的父节点不空，第二个是它本身也是父节点：
```sql
SELECT id, 'Inner' AS Type
FROM tree
WHERE id IN (
        SELECT p_id
        FROM tree
        WHERE p_id IS NOT NULL
    ) 
AND p_id IS NOT NULL;
```
将这三个结果用union连接起来，得到题目要求的结果。

```sql
SELECT id, 'Root' AS Type
FROM tree
WHERE p_id IS NULL
UNION
SELECT id, 'Leaf' AS Type
FROM tree
WHERE id NOT IN (
    SELECT p_id
    FROM tree
    WHERE p_id IS NOT NULL
)
UNION
SELECT id, 'Inner' AS Type
FROM tree
WHERE id IN (
        SELECT p_id
        FROM tree
        WHERE p_id IS NOT NULL
    ) 
AND p_id IS NOT NULL
ORDER BY id;

```

第二种方法，使用CASE WHEN语句来实现
```sql
SELECT id,
        (
            CASE WHEN p_id IS NULL THEN 'Root'
                 WHEN id IN (SELECT DISTINCT p_id FROM tree) THEN 'Inner'
                 ELSE 'Leaf'
            END
        ) AS Tpye
FROM tree
ORDER BY id;
```

第三种方法，把CASE WHEN换成IF语句
```sql
SELECT id, IF(ISNULL(p_id), 'Root', IF(id IN (SELECT p_id FROM tree), 'Inner', 'Leaf')) AS Type
FROM tree
ORDER BY id;
```

### 612	Shortest Distance in a Plane 平面上的最近距离

题目描述：

```
Table point_2d holds the coordinates (x,y) of some unique points (more than two) in a plane.

Write a query to find the shortest distance between these points rounded to 2 decimals.

| x  | y  |
|----|----|
| -1 | -1 |
| 0  | 0  |
| -1 | -2 |

The shortest distance is 1.00 from point (-1,-1) to (-1,2). So the output should be:

| shortest |
|----------|
| 1.00     |

Note: The longest distance among all the points are less than 10000.
```

解题思路：有平面上两点的坐标，应用两点之间的距离公式。

![img](https://gss2.bdstatic.com/9fo3dSag_xI4khGkpoWK1HF6hhy/baike/pic/item/11385343fbf2b211594f214ac38065380cd78e55.jpg)

通过代码：
```sql
SELECT ROUND(
         SQRT( MIN( POWER(p1.x - p2.x, 2) + POWER(p1.y - p2.y, 2) )
        ), 2) AS shortest
FROM point_2d AS p1 INNER JOIN point_2d AS p2
ON p1.x != p2.x OR p1.y != p2.y

```
这里注意表自连接后需要排除点与自身点的距离这种情况，比如(-1,-1)到(-1,-1)这样的

### 614	Second Degree Follower 二级关注者 

题目描述：

```
In facebook, there is a follow table with two columns: followee, follower.

Please write a sql query to get the amount of each follower’s follower if he/she has one.

For example:

+-------------+------------+
| followee    | follower   |
+-------------+------------+
|     A       |     B      |
|     B       |     C      |
|     B       |     D      |
|     D       |     E      |
+-------------+------------+
should output:
+-------------+------------+
| follower    | num        |
+-------------+------------+
|     B       |  2         |
|     D       |  1         |
+-------------+------------+
Explaination:
Both B and D exist in the follower list, when as a followee, B's follower is C and D, and D's follower is E. A does not exist in follower list.

Note:
Followee would not follow himself/herself in all cases.
Please display the result in follower's alphabet order.

```

解题思路：follower的follower数量??表有两列，一列是关注者follower，一列是被关注者followee， 关注者本身也可以被其他人关注，求出每一个被关注者的二次关注者（second-degree follower）个数。

首先将表自连接，找出关注者follower被哪些人关注followee：
```sql
SELECT *
FROM follow AS F1 INNER JOIN follow AS F2
ON F1.follower = F2.followee;
```
得到的结果如下，比如B，B是A的关注者(可以理解为粉丝)， 同时，B又被C关注，即C是B的粉丝，B也被D关注，所以B的num是2。
```
+----------+----------+----------+----------+
| followee | follower | followee | follower |
+----------+----------+----------+----------+
| A        | B        | B        | C        |
| A        | B        | B        | D        |
| B        | D        | D        | E        |
+----------+----------+----------+----------+
```
那么接下来把这张表按关注者F1.follower分组，统计组内个数即num

通过代码：
```sql
SELECT F1.follower, COUNT(DISTINCT F2.follower) AS 'num'
FROM follow AS F1 INNER JOIN follow AS F2
ON F1.follower = F2.followee
GROUP BY F1.follower;
```

### 626. Exchange Seats 换座位

题目描述：https://leetcode.com/problems/exchange-seats/

解题思路：这个没有思路，看了别人的解答后才会的。题中表的内容如下：
```
+---------+---------+
|    id   | student |
+---------+---------+
|    1    | Abbot   |
|    2    | Doris   |
|    3    | Emerson |
|    4    | Green   |
|    5    | Jeames  |
+---------+---------+
```
要输出的内容如下：
```
+---------+---------+
|    id   | student |
+---------+---------+
|    1    | Doris   |
|    2    | Abbot   |
|    3    | Green   |
|    4    | Emerson |
|    5    | Jeames  |
+---------+---------+
```
要求id相邻的更换学生名字，原先id=2的学生名字，更换为id=1；原先id=1的学生名字，更换为id=2的

那么可以推导出：
- 如果id=偶数，则将其id-1
- 如果id=奇数且是最后一个，则id不变； 
- 如果id=奇数且不是最后一个，则id+1

通过代码：
```sql
SELECT (CASE mod(id, 2) 
       WHEN 0 THEN id-1
       WHEN 1 AND id = (SELECT COUNT(*) FROM seat) THEN id
       ELSE id+1
       END) AS id, student
FROM seat
ORDER BY id;
```

### 1045 Customers Who Bought All Products 买下所有产品的客户

题目描述：

```
Table: Customer

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| customer_id | int     |
| product_key | int     |
+-------------+---------+
product_key is a foreign key to Product table.
Table: Product

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| product_key | int     |
+-------------+---------+
product_key is the primary key column for this table.
 

Write an SQL query for a report that provides the customer ids from the Customer table that bought all the products in the Product table.

For example:

Customer table:
+-------------+-------------+
| customer_id | product_key |
+-------------+-------------+
| 1           | 5           |
| 2           | 6           |
| 3           | 5           |
| 3           | 6           |
| 1           | 6           |
+-------------+-------------+

Product table:
+-------------+
| product_key |
+-------------+
| 5           |
| 6           |
+-------------+

Result table:
+-------------+
| customer_id |
+-------------+
| 1           |
| 3           |
+-------------+
The customers who bought all the products (5 and 6) are customers with id 1 and 3.

```

解题思路：找出买了所有商品的用户。先把用户分组，计算每个用户买的商品数量。然后计算商品表中的总数量。最后如果这两个数量相等，那就是全买了


通过代码：
```sql
SELECT customer_id
FROM Customer
GROUP BY customer_id
HAVING COUNT(DISTINCT product_key) = (
    SELECT COUNT(DISTINCT product_key) FROM Product
);
```

### 1070 Product Sales Analysis III 产品销售分析 III 

题目描述：

```
Table: Sales

+-------------+-------+
| Column Name | Type  |
+-------------+-------+
| sale_id     | int   |
| product_id  | int   |
| year        | int   |
| quantity    | int   |
| price       | int   |
+-------------+-------+
sale_id is the primary key of this table.
product_id is a foreign key to Product table.
Note that the price is per unit.
Table: Product

+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| product_id   | int     |
| product_name | varchar |
+--------------+---------+
product_id is the primary key of this table.
 

Write an SQL query that selects the product id, year, quantity, and price for the first year of every product sold.

The query result format is in the following example:

Sales table:
+---------+------------+------+----------+-------+
| sale_id | product_id | year | quantity | price |
+---------+------------+------+----------+-------+ 
| 1       | 100        | 2008 | 10       | 5000  |
| 2       | 100        | 2009 | 12       | 5000  |
| 7       | 200        | 2011 | 15       | 9000  |
+---------+------------+------+----------+-------+

Product table:
+------------+--------------+
| product_id | product_name |
+------------+--------------+
| 100        | Nokia        |
| 200        | Apple        |
| 300        | Samsung      |
+------------+--------------+

Result table:
+------------+------------+----------+-------+
| product_id | first_year | quantity | price |
+------------+------------+----------+-------+ 
| 100        | 2008       | 10       | 5000  |
| 200        | 2011       | 15       | 9000  |
+------------+------------+----------+-------+

```

解题思路：最开始是这样写的，但是不对

```sql
SELECT product_id, MIN(year) AS first_year, quantity, price
FROM Sales
GROUP BY product_id;
```

不对的原因是MIN(year)只关注一个值，而不是一行值。本题要求每个产品第一年的记录，应该需要把产品id和年份绑定在一起。

通过代码：
```sql
SELECT product_id, year AS first_year, quantity, price
FROM Sales
WHERE (product_id, year) IN (
    SELECT product_id, MIN(year) 
    FROM Sales
    GROUP BY product_id
);
```

### 1077 Project Employees III 	项目员工 III 

题目描述：

```
Table: Project
+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| project_id  | int     |
| employee_id | int     |
+-------------+---------+
(project_id, employee_id) is the primary key of this table.
employee_id is a foreign key to Employee table.

Table: Employee
+------------------+---------+
| Column Name      | Type    |
+------------------+---------+
| employee_id      | int     |
| name             | varchar |
| experience_years | int     |
+------------------+---------+
employee_id is the primary key of this table.
 

Write an SQL query that reports the most experienced employees in each project. 
In case of a tie, report all employees with the maximum number of experience years.

The query result format is in the following example:

Project table:
+-------------+-------------+
| project_id  | employee_id |
+-------------+-------------+
| 1           | 1           |
| 1           | 2           |
| 1           | 3           |
| 2           | 1           |
| 2           | 4           |
+-------------+-------------+

Employee table:
+-------------+--------+------------------+
| employee_id | name   | experience_years |
+-------------+--------+------------------+
| 1           | Khaled | 3                |
| 2           | Ali    | 2                |
| 3           | John   | 3                |
| 4           | Doe    | 2                |
+-------------+--------+------------------+

Result table:
+-------------+---------------+
| project_id  | employee_id   |
+-------------+---------------+
| 1           | 1             |
| 1           | 3             |
| 2           | 1             |
+-------------+---------------+
Both employees with id 1 and 3 have the most experience among the employees of the first project. 
For the second project, the employee with id 1 has the most experience.
```

解题思路：找出每个项目里工作经验最多的员工。先把项目表和员工表连接：
```sql
SELECT * 
FROM Project AS P LEFT JOIN Employee AS E
ON P.employee_id = E.employee_id
ORDER BY P.project_id;

```
得到的结果如下
```
+------------+-------------+-------------+------+------------------+
| project_id | employee_id | employee_id | name | experience_years |
+------------+-------------+-------------+------+------------------+
|          1 |           1 |           1 | Kh   |                3 |
|          1 |           2 |           2 | Al   |                2 |
|          1 |           3 |           3 | Jo   |                3 |
|          2 |           1 |           1 | Kh   |                3 |
|          2 |           4 |           4 | Do   |                2 |
+------------+-------------+-------------+------+------------------+
```
然后把项目分组，找出每个项目中经验最多的是多少年的：
```sql
SELECT P.project_id, MAX(E.experience_years)
FROM Project AS P LEFT JOIN Employee AS E
ON P.employee_id = E.employee_id
GROUP BY P.project_id;

```
得到结果如下：
```
+------------+-------------------------+
| project_id | MAX(E.experience_years) |
+------------+-------------------------+
|          1 |                       3 |
|          2 |                       3 |
+------------+-------------------------+

```
最后找出项目表中的项目id和员工表中的员工id，其中员工是工作经验最多的

通过代码：
```sql
SELECT P.project_id, E.employee_id
FROM Project AS P LEFT JOIN Employee AS E
ON P.employee_id = E.employee_id
WHERE (P.project_id, E.experience_years) IN 
    (
        SELECT P.project_id, MAX(E.experience_years)
        FROM Project AS P LEFT JOIN Employee AS E
        ON P.employee_id = E.employee_id
        GROUP BY P.project_id
    )
;
```
### 1098 Unpopular Books  小众书籍

题目描述：

```
Table: Books
+----------------+---------+
| Column Name    | Type    |
+----------------+---------+
| book_id        | int     |
| name           | varchar |
| available_from | date    |
+----------------+---------+
book_id is the primary key of this table.

Table: Orders
+----------------+---------+
| Column Name    | Type    |
+----------------+---------+
| order_id       | int     |
| book_id        | int     |
| quantity       | int     |
| dispatch_date  | date    |
+----------------+---------+
order_id is the primary key of this table.
book_id is a foreign key to the Books table.
 

Write an SQL query that reports the books that have sold less than 10 copies in the last year, excluding books that have been available for less than 1 month from today. Assume today is 2019-06-23.

The query result format is in the following example:

Books table:
+---------+--------------------+----------------+
| book_id | name               | available_from |
+---------+--------------------+----------------+
| 1       | "Kalila And Demna" | 2010-01-01     |
| 2       | "28 Letters"       | 2012-05-12     |
| 3       | "The Hobbit"       | 2019-06-10     |
| 4       | "13 Reasons Why"   | 2019-06-01     |
| 5       | "The Hunger Games" | 2008-09-21     |
+---------+--------------------+----------------+

Orders table:
+----------+---------+----------+---------------+
| order_id | book_id | quantity | dispatch_date |
+----------+---------+----------+---------------+
| 1        | 1       | 2        | 2018-07-26    |
| 2        | 1       | 1        | 2018-11-05    |
| 3        | 3       | 8        | 2019-06-11    |
| 4        | 4       | 6        | 2019-06-05    |
| 5        | 4       | 5        | 2019-06-20    |
| 6        | 5       | 9        | 2009-02-02    |
| 7        | 5       | 8        | 2010-04-13    |
+----------+---------+----------+---------------+

Result table:
+-----------+--------------------+
| book_id   | name               |
+-----------+--------------------+
| 1         | "Kalila And Demna" |
| 2         | "28 Letters"       |
| 5         | "The Hunger Games" |
+-----------+--------------------+

```

解题思路：找出去年到今天销量少于10的书id和名字，最近一个月才开始卖的除外。

先找出去年到今天，并且排除掉最近一个月的卖书情况：

```sql
SELECT *
FROM books AS B LEFT JOIN orders AS O
ON O.book_id = B.book_id AND O.dispatch_date BETWEEN '2018-06-23' AND '2019-06-23'
WHERE DATEDIFF('2019-06-23', B.available_from) > 30;
```
得到的卖书情况如下：
```
+---------+------+----------------+----------+---------+----------+---------------+
| book_id | name | available_from | order_id | book_id | quantity | dispatch_date |
+---------+------+----------------+----------+---------+----------+---------------+
|       1 | ka   | 2010-01-01     |        1 |       1 |        2 | 2018-07-26    |
|       1 | ka   | 2010-01-01     |        2 |       1 |        1 | 2018-11-05    |
|       2 | 28   | 2012-05-12     |     NULL |    NULL |     NULL | NULL          |
|       5 | Hu   | 2008-09-21     |     NULL |    NULL |     NULL | NULL          |
+---------+------+----------------+----------+---------+----------+---------------+

```
然后，统计每本书的销售数量，找出小于10本的，如果数量quantity是null，用IF语句转换为0

通过代码：
```sql
SELECT B.book_id, B.name
FROM books AS B LEFT JOIN orders AS O
ON O.book_id = B.book_id AND O.dispatch_date BETWEEN '2018-06-23' AND '2019-06-23'
WHERE DATEDIFF('2019-06-23', B.available_from) > 30
GROUP BY B.book_id
HAVING SUM(IF(O.quantity IS NULL, 0, O.quantity)) < 10;
```

### 1107.New Users Daily Count 每日新用户统计 
题目描述：

```
Table: Traffic

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| user_id       | int     |
| activity      | enum    |
| activity_date | date    |
+---------------+---------+
There is no primary key for this table, it may have duplicate rows.
The activity column is an ENUM type of ('login', 'logout', 'jobs', 'groups', 'homepage').
 

Write an SQL query that reports for every date within at most 90 days from today, the number of users that logged in for the first time on that date. Assume today is 2019-06-30.

The query result format is in the following example:

Traffic table:
+---------+----------+---------------+
| user_id | activity | activity_date |
+---------+----------+---------------+
| 1       | login    | 2019-05-01    |
| 1       | homepage | 2019-05-01    |
| 1       | logout   | 2019-05-01    |
| 2       | login    | 2019-06-21    |
| 2       | logout   | 2019-06-21    |
| 3       | login    | 2019-01-01    |
| 3       | jobs     | 2019-01-01    |
| 3       | logout   | 2019-01-01    |
| 4       | login    | 2019-06-21    |
| 4       | groups   | 2019-06-21    |
| 4       | logout   | 2019-06-21    |
| 5       | login    | 2019-03-01    |
| 5       | logout   | 2019-03-01    |
| 5       | login    | 2019-06-21    |
| 5       | logout   | 2019-06-21    |
+---------+----------+---------------+

Result table:
+------------+-------------+
| login_date | user_count  |
+------------+-------------+
| 2019-05-01 | 1           |
| 2019-06-21 | 2           |
+------------+-------------+
Note that we only care about dates with non zero user count.
The user with id 5 first logged in on 2019-03-01 so he's not counted on 2019-06-21.

```

解题思路：先找出每个用户最早的登陆日期

```sql
SELECT user_id, MIN(activity_date) AS login_date
FROM Traffic
WHERE activity = 'login'
GROUP BY user_id;
```
得到结果如下：
```
+---------+------------+
| user_id | login_date |
+---------+------------+
|       1 | 2019-05-01 |
|       2 | 2019-06-21 |
|       3 | 2019-01-01 |
|       4 | 2019-06-21 |
|       5 | 2019-03-01 |
+---------+------------+
```
然后找出最近90天的，并根据登陆时间分组，统计用户数量
通过代码：
```sql
SELECT login_date, COUNT(user_id) AS user_count
FROM (
	SELECT user_id, MIN(activity_date) AS login_date
	FROM Traffic
	WHERE activity = 'login'
	GROUP BY user_id
    )AS t
WHERE DATEDIFF('2019-06-30', login_date) <= 90
GROUP BY login_date;
```

### 1112 Highest Grade For Each Student 每个同学的最高分
题目描述：

```
Table: Enrollments

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| student_id    | int     |
| course_id     | int     |
| grade         | int     |
+---------------+---------+
(student_id, course_id) is the primary key of this table.

Write a SQL query to find the highest grade with its corresponding course for each student. In case of a tie, you should find the course with the smallest course_id. The output must be sorted by increasing student_id.

The query result format is in the following example:

Enrollments table:
+------------+-------------------+
| student_id | course_id | grade |
+------------+-----------+-------+
| 2          | 2         | 95    |
| 2          | 3         | 95    |
| 1          | 1         | 90    |
| 1          | 2         | 99    |
| 3          | 1         | 80    |
| 3          | 2         | 75    |
| 3          | 3         | 82    |
+------------+-----------+-------+

Result table:
+------------+-------------------+
| student_id | course_id | grade |
+------------+-----------+-------+
| 1          | 2         | 99    |
| 2          | 2         | 95    |
| 3          | 3         | 82    |
+------------+-----------+-------+

```

解题思路：题目有三个条件，第一个，找出每个学生的最高分成绩。第二个，如果多个课程的最高分相同，那么选出最小的课程id。第三个，按学生id升序排列。

首先找出每个学生的最高分数：
```sql
SELECT student_id, MAX(grade)
FROM Enrollments
GROUP BY student_id;
```

得到结果如下：
```
+------------+------------+
| student_id | MAX(grade) |
+------------+------------+
|          1 |         99 |
|          2 |         95 |
|          3 |         82 |
+------------+------------+
```
可以看出2号的最高分数是95，但是TA有两门课程都是95，按照题意应选出id=2的课程

通过代码：
```sql
SELECT student_id, MIN(course_id), grade
FROM Enrollments
WHERE (student_id, grade) IN (
    SELECT student_id, MAX(grade)
    FROM Enrollments
    GROUP BY student_id
)
GROUP BY student_id
ORDER BY student_id;
```

### 1126 Active Businesses 活跃业务
题目描述：

```
Table: Events

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| business_id   | int     |
| event_type    | varchar |
| occurences    | int     | 
+---------------+---------+
(business_id, event_type) is the primary key of this table.
Each row in the table logs the info that an event of some type occured at some business for a number of times.
 

Write an SQL query to find all active businesses.

An active business is a business that has more than one event type with occurences greater than the average occurences of that event type among all businesses.

The query result format is in the following example:

Events table:
+-------------+------------+------------+
| business_id | event_type | occurences |
+-------------+------------+------------+
| 1           | reviews    | 7          |
| 3           | reviews    | 3          |
| 1           | ads        | 11         |
| 2           | ads        | 7          |
| 3           | ads        | 6          |
| 1           | page views | 3          |
| 2           | page views | 12         |
+-------------+------------+------------+

Result table:
+-------------+
| business_id |
+-------------+
| 1           |
+-------------+ 
Average for 'reviews', 'ads' and 'page views' are (7+3)/2=5, (11+7+6)/3=8, (3+12)/2=7.5 respectively.
Business with id 1 has 7 'reviews' events (more than 5) and 11 'ads' events (more than 8) so it is an active business.

```

解题思路：求出每个事件类型的平均发生频率，找出这样的id，它有至少两种事件类型的发生频率是超过该事件类型平均发生频率的。

第一步，求出每个事件类型的平均发生频率
```sql
SELECT event_type, AVG(occurences) AS event_avg
FROM Events
GROUP BY event_type;

```
得到的结果如下：
```
+------------+-----------+
| event_type | event_avg |
+------------+-----------+
| ads        |    8.0000 |
| page views |    7.5000 |
| reviews    |    5.0000 |
+------------+-----------+
```

第二步，因为需要比较每个事件的发生次数和平均发生次数，因此把平均发生次数的列拼接到原表的右列
```sql
SELECT E.*, A.event_avg
FROM Events AS E 
LEFT JOIN (
	SELECT event_type, AVG(occurences) AS event_avg
	FROM Events
	GROUP BY event_type

) AS A 
ON E.event_type = A.event_type;

```
得到结果的如下
```
+-------------+------------+------------+-----------+
| business_id | event_type | occurences | event_avg |
+-------------+------------+------------+-----------+
|           1 | reviews    |          7 |    5.0000 |
|           3 | reviews    |          3 |    5.0000 |
|           1 | ads        |         11 |    8.0000 |
|           2 | ads        |          7 |    8.0000 |
|           3 | ads        |          6 |    8.0000 |
|           1 | page views |          3 |    7.5000 |
|           2 | page views |         12 |    7.5000 |
+-------------+------------+------------+-----------+
```
最后，对id分组，过滤出实际发生次数大于平均发生次数的，且事件数量大于1 的

通过代码：
```sql
SELECT T.business_id
FROM (
	SELECT E.*, A.event_avg
	FROM Events AS E LEFT JOIN (
		SELECT event_type, AVG(occurences) AS event_avg
		FROM Events
		GROUP BY event_type
	) AS A ON E.event_type = A.event_type
) AS T
WHERE T.occurences > T.event_avg
GROUP BY T.business_id
HAVING COUNT(T.event_type) > 1;
```

### 1132 Reported Posts II
题目描述：

```
Table: Actions

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| user_id       | int     |
| post_id       | int     |
| action_date   | date    |
| action        | enum    |
| extra         | varchar |
+---------------+---------+
There is no primary key for this table, it may have duplicate rows.
The action column is an ENUM type of ('view', 'like', 'reaction', 'comment', 'report', 'share').
The extra column has optional information about the action such as a reason for report or a type of reaction. 
Table: Removals

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| post_id       | int     |
| remove_date   | date    | 
+---------------+---------+
post_id is the primary key of this table.
Each row in this table indicates that some post was removed as a result of being reported or as a result of an admin review.
 

Write an SQL query to find the average for daily percentage of posts that got removed after being reported as spam, rounded to 2 decimal places.

The query result format is in the following example:

Actions table:
+---------+---------+-------------+--------+--------+
| user_id | post_id | action_date | action | extra  |
+---------+---------+-------------+--------+--------+
| 1       | 1       | 2019-07-01  | view   | null   |
| 1       | 1       | 2019-07-01  | like   | null   |
| 1       | 1       | 2019-07-01  | share  | null   |
| 2       | 2       | 2019-07-04  | view   | null   |
| 2       | 2       | 2019-07-04  | report | spam   |
| 3       | 4       | 2019-07-04  | view   | null   |
| 3       | 4       | 2019-07-04  | report | spam   |
| 4       | 3       | 2019-07-02  | view   | null   |
| 4       | 3       | 2019-07-02  | report | spam   |
| 5       | 2       | 2019-07-03  | view   | null   |
| 5       | 2       | 2019-07-03  | report | racism |
| 5       | 5       | 2019-07-03  | view   | null   |
| 5       | 5       | 2019-07-03  | report | racism |
+---------+---------+-------------+--------+--------+

Removals table:
+---------+-------------+
| post_id | remove_date |
+---------+-------------+
| 2       | 2019-07-20  |
| 3       | 2019-07-18  |
+---------+-------------+

Result table:
+-----------------------+
| average_daily_percent |
+-----------------------+
| 75.00                 |
+-----------------------+
The percentage for 2019-07-04 is 50% because only one post of two spam reported posts was removed.
The percentage for 2019-07-02 is 100% because one post was reported as spam and it was removed.
The other days had no spam reports so the average is (50 + 100) / 2 = 75%
Note that the output is only one number and that we do not care about the remove dates.

```

解题思路：


通过代码：
```sql


```


### 1149 Article Views II  
题目描述：

```
Table: Views

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| article_id    | int     |
| author_id     | int     |
| viewer_id     | int     |
| view_date     | date    |
+---------------+---------+
There is no primary key for this table, it may have duplicate rows.
Each row of this table indicates that some viewer viewed an article (written by some author) on some date. 
Note that equal author_id and viewer_id indicate the same person.
 

Write an SQL query to find all the people who viewed more than one article on the same date, sorted in ascending order by their id.

The query result format is in the following example:

Views table:
+------------+-----------+-----------+------------+
| article_id | author_id | viewer_id | view_date  |
+------------+-----------+-----------+------------+
| 1          | 3         | 5         | 2019-08-01 |
| 3          | 4         | 5         | 2019-08-01 |
| 1          | 3         | 6         | 2019-08-02 |
| 2          | 7         | 7         | 2019-08-01 |
| 2          | 7         | 6         | 2019-08-02 |
| 4          | 7         | 1         | 2019-07-22 |
| 3          | 4         | 4         | 2019-07-21 |
| 3          | 4         | 4         | 2019-07-21 |
+------------+-----------+-----------+------------+

Result table:
+------+
| id   |
+------+
| 5    |
| 6    |
+------+

```

解题思路：那么先按阅读者-日期分组，找出某读者在该日期阅读的文章数量总和
```sql
SELECT COUNT(DISTINCT article_id) AS articles, viewer_id as id
FROM Views
GROUP BY viewer_id, view_date;

```
得出结果如下：
```
+----------+------+
| articles | id   |
+----------+------+
|        1 |    1 |
|        1 |    4 |
|        2 |    5 |
|        2 |    6 |
|        1 |    7 |
+----------+------+

```
然后找出文章总数量超过1的读者id

通过代码：
```sql
SELECT DISTINCT t.id
FROM (
	SELECT COUNT(DISTINCT article_id) AS articles, viewer_id as id
	FROM Views
	GROUP BY viewer_id, view_date
) AS t
WHERE t.articles > 1
ORDER BY t.id;

```

### 1158 Market Analysis I
题目描述：

```
Table: Users

+----------------+---------+
| Column Name    | Type    |
+----------------+---------+
| user_id        | int     |
| join_date      | date    |
| favorite_brand | varchar |
+----------------+---------+
user_id is the primary key of this table.
This table has the info of the users of an online shopping website where users can sell and buy items.
Table: Orders

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| order_id      | int     |
| order_date    | date    |
| item_id       | int     |
| buyer_id      | int     |
| seller_id     | int     |
+---------------+---------+
order_id is the primary key of this table.
item_id is a foreign key to the Items table.
buyer_id and seller_id are foreign keys to the Users table.
Table: Items

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| item_id       | int     |
| item_brand    | varchar |
+---------------+---------+
item_id is the primary key of this table.
 

Write an SQL query to find for each user, the join date and the number of orders they made as a buyer in 2019.

The query result format is in the following example:

Users table:
+---------+------------+----------------+
| user_id | join_date  | favorite_brand |
+---------+------------+----------------+
| 1       | 2018-01-01 | Lenovo         |
| 2       | 2018-02-09 | Samsung        |
| 3       | 2018-01-19 | LG             |
| 4       | 2018-05-21 | HP             |
+---------+------------+----------------+

Orders table:
+----------+------------+---------+----------+-----------+
| order_id | order_date | item_id | buyer_id | seller_id |
+----------+------------+---------+----------+-----------+
| 1        | 2019-08-01 | 4       | 1        | 2         |
| 2        | 2018-08-02 | 2       | 1        | 3         |
| 3        | 2019-08-03 | 3       | 2        | 3         |
| 4        | 2018-08-04 | 1       | 4        | 2         |
| 5        | 2018-08-04 | 1       | 3        | 4         |
| 6        | 2019-08-05 | 2       | 2        | 4         |
+----------+------------+---------+----------+-----------+

Items table:
+---------+------------+
| item_id | item_brand |
+---------+------------+
| 1       | Samsung    |
| 2       | Lenovo     |
| 3       | LG         |
| 4       | HP         |
+---------+------------+

Result table:
+-----------+------------+----------------+
| buyer_id  | join_date  | orders_in_2019 |
+-----------+------------+----------------+
| 1         | 2018-01-01 | 1              |
| 2         | 2018-02-09 | 2              |
| 3         | 2018-01-19 | 0              |
| 4         | 2018-05-21 | 0              |
+-----------+------------+----------------+

```

解题思路：每个用户的id，加入时间，在2019年的订单数量。首先找出每个用户每一笔的订单情况：
```sql
SELECT O.buyer_id, O.order_date, U.join_date
FROM Orders2 AS O LEFT JOIN Users AS U
ON O.buyer_id = U.user_id
GROUP BY O.buyer_id, O.order_date;
```
得到的结果：
```
+----------+------------+------------+
| buyer_id | order_date | join_date  |
+----------+------------+------------+
|        1 | 2018-08-02 | 2018-01-01 |
|        1 | 2019-08-01 | 2018-01-01 |
|        2 | 2019-08-03 | 2018-02-09 |
|        2 | 2019-08-05 | 2018-02-09 |
|        3 | 2018-08-04 | 2018-01-19 |
|        4 | 2018-08-04 | 2018-05-21 |
+----------+------------+------------+

```
以这个表为基础，按购买者id分类，统计其在2019年的订单总量，

通过代码：
```sql
SELECT t.buyer_id, t.join_date, SUM(IF(YEAR(t.order_date)=2019, 1,0)) AS orders_id_2019
FROM (
	SELECT O.buyer_id, O.order_date, U.join_date
	FROM Orders2 AS O LEFT JOIN Users AS U
	ON O.buyer_id = U.user_id
	GROUP BY O.buyer_id, O.order_date
) AS t
GROUP BY t.buyer_id;
```

### 1164 Product Price at a Given Date
题目描述：

```
Table: Products

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| product_id    | int     |
| new_price     | int     |
| change_date   | date    |
+---------------+---------+
(product_id, change_date) is the primary key of this table.
Each row of this table indicates that the price of some product was changed to a new price at some date.
 

Write an SQL query to find the prices of all products on 2019-08-16. Assume the price of all products before any change is 10.

The query result format is in the following example:

Products table:
+------------+-----------+-------------+
| product_id | new_price | change_date |
+------------+-----------+-------------+
| 1          | 20        | 2019-08-14  |
| 2          | 50        | 2019-08-14  |
| 1          | 30        | 2019-08-15  |
| 1          | 35        | 2019-08-16  |
| 2          | 65        | 2019-08-17  |
| 3          | 20        | 2019-08-18  |
+------------+-----------+-------------+

Result table:
+------------+-------+
| product_id | price |
+------------+-------+
| 2          | 50    |
| 1          | 35    |
| 3          | 10    |
+------------+-------+

```

解题思路：


通过代码：
```sql


```

### 1174 Immediate Food Delivery II  
题目描述：

```
Table: Delivery

+-----------------------------+---------+
| Column Name                 | Type    |
+-----------------------------+---------+
| delivery_id                 | int     |
| customer_id                 | int     |
| order_date                  | date    |
| customer_pref_delivery_date | date    |
+-----------------------------+---------+
delivery_id is the primary key of this table.
The table holds information about food delivery to customers that make orders at some date and specify a preferred delivery date (on the same order date or after it).
 

If the preferred delivery date of the customer is the same as the order date then the order is called immediate otherwise it's called scheduled.

The first order of a customer is the order with the earliest order date that customer made. It is guaranteed that a customer has exactly one first order.

Write an SQL query to find the percentage of immediate orders in the first orders of all customers, rounded to 2 decimal places.

The query result format is in the following example:

Delivery table:
+-------------+-------------+------------+-----------------------------+
| delivery_id | customer_id | order_date | customer_pref_delivery_date |
+-------------+-------------+------------+-----------------------------+
| 1           | 1           | 2019-08-01 | 2019-08-02                  |
| 2           | 2           | 2019-08-02 | 2019-08-02                  |
| 3           | 1           | 2019-08-11 | 2019-08-12                  |
| 4           | 3           | 2019-08-24 | 2019-08-24                  |
| 5           | 3           | 2019-08-21 | 2019-08-22                  |
| 6           | 2           | 2019-08-11 | 2019-08-13                  |
| 7           | 4           | 2019-08-09 | 2019-08-09                  |
+-------------+-------------+------------+-----------------------------+

Result table:
+----------------------+
| immediate_percentage |
+----------------------+
| 50.00                |
+----------------------+
The customer id 1 has a first order with delivery id 1 and it is scheduled.
The customer id 2 has a first order with delivery id 2 and it is immediate.
The customer id 3 has a first order with delivery id 5 and it is scheduled.
The customer id 4 has a first order with delivery id 7 and it is immediate.
Hence, half the customers have immediate first orders.

```

解题思路：


通过代码：
```sql


```

### 1193 Monthly Transactions I
题目描述：

```
Table: Transactions

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| id            | int     |
| country       | varchar |
| state         | enum    |
| amount        | int     |
| trans_date    | date    |
+---------------+---------+
id is the primary key of this table.
The table has information about incoming transactions.
The state column is an enum of type ["approved", "declined"].
 

Write an SQL query to find for each month and country, the number of transactions and their total amount, the number of approved transactions and their total amount.

The query result format is in the following example:

Transactions table:
+------+---------+----------+--------+------------+
| id   | country | state    | amount | trans_date |
+------+---------+----------+--------+------------+
| 121  | US      | approved | 1000   | 2018-12-18 |
| 122  | US      | declined | 2000   | 2018-12-19 |
| 123  | US      | approved | 2000   | 2019-01-01 |
| 124  | DE      | approved | 2000   | 2019-01-07 |
+------+---------+----------+--------+------------+

Result table:
+----------+---------+-------------+----------------+--------------------+-----------------------+
| month    | country | trans_count | approved_count | trans_total_amount | approved_total_amount |
+----------+---------+-------------+----------------+--------------------+-----------------------+
| 2018-12  | US      | 2           | 1              | 3000               | 1000                  |
| 2019-01  | US      | 1           | 1              | 2000               | 2000                  |
| 2019-01  | DE      | 1           | 1              | 2000               | 2000                  |
+----------+---------+-------------+----------------+--------------------+-----------------------+

```

解题思路：根据月份和国家分组，然后统计每组内的题目要求的数据即可。

通过代码：
```sql
SELECT 
	LEFT(trans_date, 7) AS 'month', 
    country, 
    COUNT(id) AS 'trans_count', 
    SUM(IF(state='approved', 1,0)) AS 'approved_count', 
    SUM(amount) AS 'trans_total_amount', 
    IF(state='approved', amount, 0) AS 'approved_total_amount'
FROM Transactions
GROUP BY MONTH(trans_date), country
ORDER BY trans_count DESC;
```

### 1204. Last Person to Fit in the Elevator
题目描述：

```
Table: Queue

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| person_id   | int     |
| person_name | varchar |
| weight      | int     |
| turn        | int     |
+-------------+---------+
person_id is the primary key column for this table.
This table has the information about all people waiting for an elevator.
The person_id and turn columns will contain all numbers from 1 to n, where n is the number of rows in the table.
 

The maximum weight the elevator can hold is 1000.

Write an SQL query to find the person_name of the last person who will fit in the elevator without exceeding the weight limit. It is guaranteed that the person who is first in the queue can fit in the elevator.

The query result format is in the following example:

Queue table
+-----------+-------------------+--------+------+
| person_id | person_name       | weight | turn |
+-----------+-------------------+--------+------+
| 5         | George Washington | 250    | 1    |
| 3         | John Adams        | 350    | 2    |
| 6         | Thomas Jefferson  | 400    | 3    |
| 2         | Will Johnliams    | 200    | 4    |
| 4         | Thomas Jefferson  | 175    | 5    |
| 1         | James Elephant    | 500    | 6    |
+-----------+-------------------+--------+------+

Result table
+-------------------+
| person_name       |
+-------------------+
| Thomas Jefferson  |
+-------------------+

Queue table is ordered by turn in the example for simplicity.
In the example George Washington(id 5), John Adams(id 3) and Thomas Jefferson(id 6) will enter the elevator as their weight sum is 250 + 350 + 400 = 1000.
Thomas Jefferson(id 6) is the last person to fit in the elevator because he has the last turn in these three people.

```

解题思路：按照进电梯的顺序对每个人的体重累加，求出累加和为1000时的人的名字。先对weight进行累加：
```sql
SELECT *, (
    SELECT SUM(weight)
    FROM Queue
    WHERE turn <= Q.turn
) AS leijia
FROM Queue AS Q
ORDER BY turn;

```
得到结果如下：
```
+-----------+-------------------+--------+------+--------+
| person_id | person_name       | weight | turn | leijia |
+-----------+-------------------+--------+------+--------+
|         5 | George Washington |    250 |    1 |    250 |
|         3 | John Adams        |    350 |    2 |    600 |
|         6 | Thomas Jefferson  |    400 |    3 |   1000 |
|         2 | Will Johnliams    |    200 |    4 |   1200 |
|         4 | Thomas Jefferson  |    175 |    5 |   1375 |
|         1 | James Elephant    |    500 |    6 |   1875 |
+-----------+-------------------+--------+------+--------+
```
再以这张表为基础，找出leijia列值为1000的人的名字
通过代码：
```sql
SELECT person_name 
FROM (
    SELECT *, (
            SELECT SUM(weight)
            FROM Queue
            WHERE turn <= Q.turn
        ) AS leijia
    FROM Queue AS Q
) AS t
WHERE t.leijia = 1000
ORDER BY turn;

```

### 1205 Monthly Transactions II
题目描述：

```
Table: Transactions

+----------------+---------+
| Column Name    | Type    |
+----------------+---------+
| id             | int     |
| country        | varchar |
| state          | enum    |
| amount         | int     |
| trans_date     | date    |
+----------------+---------+
id is the primary key of this table.
The table has information about incoming transactions.
The state column is an enum of type ["approved", "declined"].
Table: Chargebacks

+----------------+---------+
| Column Name    | Type    |
+----------------+---------+
| trans_id       | int     |
| charge_date    | date    |
+----------------+---------+
Chargebacks contains basic information regarding incoming chargebacks from some transactions placed in Transactions table.
trans_id is a foreign key to the id column of Transactions table.
Each chargeback corresponds to a transaction made previously even if they were not approved.
 

Write an SQL query to find for each month and country, the number of approved transactions and their total amount, the number of chargebacks and their total amount.

Note: In your query, given the month and country, ignore rows with all zeros.

The query result format is in the following example:

Transactions table:
+------+---------+----------+--------+------------+
| id   | country | state    | amount | trans_date |
+------+---------+----------+--------+------------+
| 101  | US      | approved | 1000   | 2019-05-18 |
| 102  | US      | declined | 2000   | 2019-05-19 |
| 103  | US      | approved | 3000   | 2019-06-10 |
| 104  | US      | approved | 4000   | 2019-06-13 |
| 105  | US      | approved | 5000   | 2019-06-15 |
+------+---------+----------+--------+------------+

Chargebacks table:
+------------+------------+
| trans_id   | trans_date |
+------------+------------+
| 102        | 2019-05-29 |
| 101        | 2019-06-30 |
| 105        | 2019-09-18 |
+------------+------------+

Result table:
+----------+---------+----------------+-----------------+-------------------+--------------------+
| month    | country | approved_count | approved_amount | chargeback_count  | chargeback_amount  |
+----------+---------+----------------+-----------------+-------------------+--------------------+
| 2019-05  | US      | 1              | 1000            | 1                 | 2000               |
| 2019-06  | US      | 3              | 12000           | 1                 | 1000               |
| 2019-09  | US      | 0              | 0               | 1                 | 5000               |
+----------+---------+----------------+-----------------+-------------------+--------------------+

```

解题思路：


通过代码：
```sql


```

### 1212 Team Scores in Football Tournament
题目描述：

```
Table: Teams

+---------------+----------+
| Column Name   | Type     |
+---------------+----------+
| team_id       | int      |
| team_name     | varchar  |
+---------------+----------+
team_id is the primary key of this table.
Each row of this table represents a single football team.

Table: Matches
+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| match_id      | int     |
| host_team     | int     |
| guest_team    | int     | 
| host_goals    | int     |
| guest_goals   | int     |
+---------------+---------+
match_id is the primary key of this table.
Each row is a record of a finished match between two different teams. 
Teams host_team and guest_team are represented by their IDs in the teams table (team_id) and they scored host_goals and guest_goals goals respectively.
 
You would like to compute the scores of all teams after all matches. Points are awarded as follows:
A team receives three points if they win a match (Score strictly more goals than the opponent team).
A team receives one point if they draw a match (Same number of goals as the opponent team).
A team receives no points if they lose a match (Score less goals than the opponent team).

Write an SQL query that selects the team_id, team_name and num_points of each team in the tournament after all described matches. Result table should be ordered by num_points (decreasing order). In case of a tie, order the records by team_id (increasing order).

The query result format is in the following example:

Teams table:
+-----------+--------------+
| team_id   | team_name    |
+-----------+--------------+
| 10        | Leetcode FC  |
| 20        | NewYork FC   |
| 30        | Atlanta FC   |
| 40        | Chicago FC   |
| 50        | Toronto FC   |
+-----------+--------------+

Matches table:
+------------+--------------+---------------+-------------+--------------+
| match_id   | host_team    | guest_team    | host_goals  | guest_goals  |
+------------+--------------+---------------+-------------+--------------+
| 1          | 10           | 20            | 3           | 0            |
| 2          | 30           | 10            | 2           | 2            |
| 3          | 10           | 50            | 5           | 1            |
| 4          | 20           | 30            | 1           | 0            |
| 5          | 50           | 30            | 1           | 0            |
+------------+--------------+---------------+-------------+--------------+

Result table:
+------------+--------------+---------------+
| team_id    | team_name    | num_points    |
+------------+--------------+---------------+
| 10         | Leetcode FC  | 7             |
| 20         | NewYork FC   | 3             |
| 50         | Toronto FC   | 3             |
| 30         | Atlanta FC   | 1             |
| 40         | Chicago FC   | 0             |
+------------+--------------+---------------+

```

解题思路：


通过代码：
```sql


```

