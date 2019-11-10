
本文包含LeetCode中hard部分的SQL练习题的解题思路和通过代码，关于题目描述可以查看[leetcode原网站](https://leetcode.com/problemset/database/)，或者[leetcode中文网站](https://leetcode-cn.com/problemset/database/)

关于带锁的部分练习，由于博主没有开会员，所以没有在LeetCode网站上测试过，参考了别的博客写的。

Easy部分的练习题：[点击这里](https://huanyouchen.github.io/2019/09/11/SQL-exercises-in-LeetCode-easy-part/)
Medium部分的练习题：[点击这里](https://huanyouchen.github.io/2019/09/11/SQL-exercises-LeetCode-medium-part/)

<!--more-->

### 185	Department Top Three Salaries 部门工资前三高的所有员工 

题目描述：https://leetcode.com/problems/department-top-three-salaries/

输出每个部门工资最高的一批人，工资第二高的一批人，工资第三高的一批人。
解题思路：

最简单的方法是用窗口函数，把员工表按部门分组，在组内按薪水逆序排序，把这个排序结果表和部门表连接，连接后取各部门薪水前三的
```sql
select d.Name as Department, a. Name as Employee, a. Salary 
from (
    select e.*, dense_rank() over (partition by DepartmentId order by Salary desc) as DeptPayRank 
    from Employee e 
) a 
join Department d
on a.DepartmentId = d.Id 
where DeptPayRank <=3; 
```

第二种方法稍微不好理解点，过程如下：

首先找出部门不同的工资总共有多少，

```sql
SELECT DISTINCT Salary
FROM Employee;

```
得到结果：
```
+--------+
| Salary |
+--------+
|  85000 |
|  80000 |
|  60000 |
|  90000 |
|  69000 |
|  70000 |
+--------+
```
找出一个部门中，工资最高，第二，第三高的。比如题目中的IT部门，工资分别为[90000, 85000, 85000, 70000, 69000]，要取出前三高的，即

```sql
SELECT E1.salary
FROM Employee AS E1
WHERE 3 > (
    SELECT COUNT(DISTINCT E2.Salary)
    FROM Employee AS E2
    WHERE E1.Salary < E2.Salary AND E1.DepartmentId = E2.DepartmentId
);

```
当 e1 = e2 = [90000, 85000, 85000, 70000, 69000]时：

e1.Salary = 69000，e2.Salary 可以取值 [90000, 85000, 85000, 70000]，count(DISTINCT e2.Salary) = 3

e1.Salary = 70000，e2.Salary 可以取值 [90000, 85000, 85000]，count(DISTINCT e2.Salary) = 2

e1.Salary = 85000，e2.Salary 可以取值[90000]，count(DISTINCT e2.Salary) = 1

e1.Salary = 90000，e2.Salary 可以取值 []，count(DISTINCT e2.Salary) = 0


最后 3 > count(DISTINCT e2.Salary)，所以 e1.Salary 可取值为 [90000, 85000, 85000, 70000]，即集合前 3 高的薪水

同样的Sales部门，工资分别为[8000, 60000], e1.Salary 可取值为[8000, 60000]

最后再把部门表连接起来：

代码：
```sql
SELECT D.Name AS Department, E1.Name AS Employee, E1.Salary AS Salary
FROM Employee AS E1 LEFT JOIN Department AS D
ON E1.departmentId = D.Id
WHERE 3 > (
    SELECT COUNT(DISTINCT E2.Salary)
    FROM Employee AS E2
    WHERE E1.Salary < E2.Salary AND E1.DepartmentId = E2.departmentId
)
ORDER BY Department, Salary DESC;

```

但是这样提交不对，错误提示例子：
```
Input:
{"headers": {"Employee": ["Id", "Name", "Salary", "DepartmentId"], "Department": ["Id", "Name"]}, "rows": {"Employee": [[1, "Joe", 10000, 1]], "Department": []}}
Output:
{"headers": ["Department", "Employee", "Salary"], "values": [[null, "Joe", 10000]]}
Expected:
{"headers":["Department","Employee","Salary"],"values":[]}

```
题中考虑了Department表为空的情况，这时输出应该也为空。而我使用的是LEFT JOIN，还是输出了值。因此需要把两表连接方式改为INNER JOIN

通过代码：
```sql
# Write your MySQL query statement below
SELECT D.Name AS Department, E1.Name AS Employee, E1.Salary AS Salary
FROM Employee AS E1 INNER JOIN Department AS D
ON E1.departmentId = D.Id
WHERE 3 > (
    SELECT COUNT(DISTINCT E2.Salary)
    FROM Employee AS E2
    WHERE E1.Salary < E2.Salary AND E1.DepartmentId = E2.departmentId
)
ORDER BY Department, Salary DESC;

```

### 262. Trips and Users

题目描述：https://leetcode.com/problems/trips-and-users/

解题思路：

第一种方法，先在Trips表中，按题目要求把时间在2013-10-01到2013-10-02之外的全排除，把客户和司机是被禁止的也全都排除。之后，按照日期分组，计算每组内的取消概率。

通过代码：

```sql
SELECT 
    Request_at AS 'Day', 
    ROUND(SUM(IF(Status='completed', 0, 1)) / COUNT(id), 2) AS 'Cancellation Rate'
FROM trips
WHERE Client_id IN (
    SELECT Users_id
    FROM Users
    WHERE Banned = 'No'
)
AND Driver_Id IN (
    SELECT Users_id
    FROM Users
    WHERE Banned = 'No'
)
AND Request_at between '2013-10-01' AND '2013-10-03'
GROUP BY Request_at;
```

### 601	Human Traffic of Stadium    

题目描述：https://leetcode.com/problems/human-traffic-of-stadium/

解题思路：首先在表中把流量少于100的都排除，然后可以利用表中的id判断日期至少连续的三天

```sql
SELECT a.*
FROM stadium as a,stadium as b,stadium as c
where (a.id = b.id-1 and b.id = c.id-1) 
  and (a.people>=100 and b.people>=100 and c.people>=100);
```

得到的结果如下：
```
+------+------------+--------+
| id   | visit_date | people |
+------+------------+--------+
|    5 | 2017-01-05 |    145 |
|    6 | 2017-01-06 |   1455 |
+------+------------+--------+
```
按题目中的条件应该输出的是5，6，7，8，但是这样写只输出了5和6，即[5,6,7]和[6,7,8]这两个连续三天中的最小的天数id，
原因在于`(a.id = b.id-1 and b.id = c.id-1) `把a设为了三个连续值中的最小值，因此需要改变这个写法：
```sql
SELECT a.*
FROM stadium as a,stadium as b,stadium as c
where a.people>=100 and b.people>=100 and c.people>=100
and(
   (a.id = b.id-1 and b.id = c.id-1)  -- a,b,c
or (b.id = a.id-1 and a.id = c.id-1)  -- b,a,c
or (c.id = b.id-1 and b.id = a.id-1)  -- c,b,a
);

```

得到结果
```
+------+------------+--------+
| id   | visit_date | people |
+------+------------+--------+
|    7 | 2017-01-07 |    199 |
|    8 | 2017-01-08 |    188 |
|    6 | 2017-01-06 |   1455 |
|    5 | 2017-01-05 |    145 |
|    7 | 2017-01-07 |    199 |
|    6 | 2017-01-06 |   1455 |
+------+------------+--------+
```
可以看出[5,6,7]和[6,7,8]这两个连续超过100人数三次的，6和7重复出现了一次，因此再对这个结果去重

通过代码：

```sql
SELECT DISTINCT a.*
FROM stadium as a,stadium as b,stadium as c
where a.people>=100 and b.people>=100 and c.people>=100
and(
   (a.id = b.id-1 and b.id = c.id-1)  -- a,b,c   a是第一天
or (b.id = a.id-1 and a.id = c.id-1)  -- b,a,c   a是第二天
or (c.id = b.id-1 and b.id = a.id-1)  -- c,b,a   a是第三天
)
ORDER BY a.id;
```

### 569	Median Employee Salary	员工薪水中位数

题目描述：
```

The Employee table holds all employees. The employee table has three columns: Employee Id, Company Name, and Salary.
+-----+------------+--------+
|Id   | Company    | Salary |
+-----+------------+--------+
|1    | A          | 2341   |
|2    | A          | 341    |
|3    | A          | 15     |
|4    | A          | 15314  |
|5    | A          | 451    |
|6    | A          | 513    |
|7    | B          | 15     |
|8    | B          | 13     |
|9    | B          | 1154   |
|10   | B          | 1345   |
|11   | B          | 1221   |
|12   | B          | 234    |
|13   | C          | 2345   |
|14   | C          | 2645   |
|15   | C          | 2645   |
|16   | C          | 2652   |
|17   | C          | 65     |
+-----+------------+--------+
Write a SQL query to find the median salary of each company. 
Bonus points if you can solve it without using any built-in SQL functions.
+-----+------------+--------+
|Id   | Company    | Salary |
+-----+------------+--------+
|5    | A          | 451    |
|6    | A          | 513    |
|12   | B          | 234    |
|9    | B          | 1154   |
|14   | C          | 2645   |
+-----+------------+--------+
```

解题思路：先把公司分组，然后算一下每组公司的员工数量，把工资排序，取中位数的工资。这道题本来以为简单的，结果写了半天都没写对。。还是看别人写的。

主要在于中位数的判断。看别人的解题思路，中位数的特点在于：
```
ABS(所有大于等于中位数的数字的数量 - 所有小于等于中位数的数字的数量) <= 1
```

通过代码：

```sql
SELECT * 
FROM employee AS E
WHERE ABS(
	(SELECT COUNT(Id) FROM Employee AS E1 WHERE E1.Company = E.Company AND E1.Salary <= E.Salary)
    -
    (SELECT COUNT(Id) FROM Employee AS E2 WHERE E2.Company = E.Company AND E2.Salary >= E.Salary)
	) <= 1
GROUP BY Company, Salary;
```

###	571	Find Median Given Frequency of Numbers 	给定数字的频率查询中位数

题目描述：
```
The Numbers table keeps the value of number and its frequency.

+----------+-------------+
|  Number  |  Frequency  |
+----------+-------------|
|  0       |  7          |
|  1       |  1          |
|  2       |  3          |
|  3       |  1          |
+----------+-------------+
In this table, the numbers are 0, 0, 0, 0, 0, 0, 0, 1, 2, 2, 2, 3, so the median is (0 + 0) / 2 = 0.

+--------+
| median |
+--------|
| 0.0000 |
+--------+
Write a query to find the median of all numbers and name the result as median.
```

解题思路：这个还没搞懂，代码抄别人的。。


通过代码：

```sql
SELECT AVG(n.Number) AS median
FROM Numbers n
WHERE n.Frequency >= ABS((SELECT SUM(Frequency) FROM Numbers WHERE Number <= n.Number) -
                         (SELECT SUM(Frequency) FROM Numbers WHERE Number >= n.Number))

```

### 579	Find Cumulative Salary of an Employee  查询员工的累计薪水

题目描述：
```
The Employee table holds the salary information in a year.

Write a SQL to get the cumulative sum of an employee's salary over a period of 3 months but exclude the most recent month.

The result should be displayed by 'Id' ascending, and then by 'Month' descending.

Example
Input

| Id | Month | Salary |
|----|-------|--------|
| 1  | 1     | 20     |
| 2  | 1     | 20     |
| 1  | 2     | 30     |
| 2  | 2     | 30     |
| 3  | 2     | 40     |
| 1  | 3     | 40     |
| 3  | 3     | 60     |
| 1  | 4     | 60     |
| 3  | 4     | 70     |
Output

| Id | Month | Salary |
|----|-------|--------|
| 1  | 3     | 90     |
| 1  | 2     | 50     |
| 1  | 1     | 20     |
| 2  | 1     | 20     |
| 3  | 3     | 100    |
| 3  | 2     | 40     |
 

Explanation
Employee '1' has 3 salary records for the following 3 months except the most recent month '4': salary 40 for month '3', 30 for month '2' and 20 for month '1'
So the cumulative sum of salary of this employee over 3 months is 90(40+30+20), 50(30+20) and 20 respectively.

| Id | Month | Salary |
|----|-------|--------|
| 1  | 3     | 90     |
| 1  | 2     | 50     |
| 1  | 1     | 20     |
Employee '2' only has one salary record (month '1') except its most recent month '2'.
| Id | Month | Salary |
|----|-------|--------|
| 2  | 1     | 20     |
 

Employ '3' has two salary records except its most recent pay month '4': month '3' with 60 and month '2' with 40. So the cumulative salary is as following.
| Id | Month | Salary |
|----|-------|--------|
| 3  | 3     | 100    |
| 3  | 2     | 40     |

```

解题思路：

通过代码：

第一种方法：
```sql
SELECT
    a.id, 
    a.month,
    SUM(b.salary) Salary
FROM
    Employee a JOIN Employee b ON
    a.id = b.id AND
    a.month - b.month >= 0 AND
    a.month - b.month < 3
GROUP BY
    a.id, a.month
HAVING
    (a.id, a.month) NOT IN (SELECT id, MAX(month) FROM Employee GROUP BY id)
ORDER BY
    a.id, a.month DESC

```

第二种方法：
```sql
SELECT e1.Id, MAX(e2.Month) AS Month, SUM(e2.Salary) AS Salary
FROM Employee e1, Employee e2
WHERE e1.Id = e2.Id AND e2.Month BETWEEN (e1.Month - 3) AND (e1.Month - 1)
GROUP BY e1.Id, e1.Month
ORDER BY Id, Month DESC;
```

###	615	Average Salary: Departments VS Company 平均工资：部门与公司比较

题目描述：
```
Given two tables as below, write a query to display the comparison result (higher/lower/same) of the average salary of employees in a department to the company's average salary.
 
Table: salary
| id | employee_id | amount | pay_date   |
|----|-------------|--------|------------|
| 1  | 1           | 9000   | 2017-03-31 |
| 2  | 2           | 6000   | 2017-03-31 |
| 3  | 3           | 10000  | 2017-03-31 |
| 4  | 1           | 7000   | 2017-02-28 |
| 5  | 2           | 6000   | 2017-02-28 |
| 6  | 3           | 8000   | 2017-02-28 |

The employee_id column refers to the employee_id in the following table employee.

| employee_id | department_id |
|-------------|---------------|
| 1           | 1             |
| 2           | 2             |
| 3           | 2             |
 
So for the sample data above, the result is:

| pay_month | department_id | comparison  |
|-----------|---------------|-------------|
| 2017-03   | 1             | higher      |
| 2017-03   | 2             | lower       |
| 2017-02   | 1             | same        |
| 2017-02   | 2             | same        |
 

Explanation
 
In March, the company's average salary is (9000+6000+10000)/3 = 8333.33...

The average salary for department '1' is 9000, which is the salary of employee_id '1' since there is only one employee in this department. So the comparison result is 'higher' since 9000 > 8333.33 obviously.
 
The average salary of department '2' is (6000 + 10000)/2 = 8000, which is the average of employee_id '2' and '3'. So the comparison result is 'lower' since 8000 < 8333.33.

With he same formula for the average salary comparison in February, the result is 'same' since both the department '1' and '2' have the same average salary with the company, which is 7000.
```

解题思路：显示部门员工平均工资与公司平均工资的比较结果(更高/更低/相同)。

那么先找出公司每个月的平均工资：
```sql
SELECT *, AVG(amount) AS `avg_salary`
FROM salary AS s JOIN employee AS e
ON s.employee_id = e.employee_id
GROUP BY LEFT(s.pay_date, 7)
ORDER BY LEFT(s.pay_date, 7) DESC
;

```
得到结果：
```
+------+-------------+--------+------------+-------------+---------------+------------+
| id   | employee_id | amount | pay_date   | employee_id | department_id | avg_salary |
+------+-------------+--------+------------+-------------+---------------+------------+
|    1 |           1 |   9000 | 2017-03-31 |           1 |             1 |  8333.3333 |
|    4 |           1 |   7000 | 2017-02-28 |           1 |             1 |  7000.0000 |
+------+-------------+--------+------------+-------------+---------------+------------+
```

然后找每个部门的每月平均工资：
```sql
SELECT *,  AVG(amount) AS `dept_avg_salary`
FROM salary AS s JOIN employee AS e 
ON s.employee_id = e.employee_id
GROUP BY LEFT(s.pay_date, 7), e.department_id
ORDER BY LEFT(s.pay_date, 7) DESC
;
```
得到结果：
```
+------+-------------+--------+------------+-------------+---------------+-----------------+
| id   | employee_id | amount | pay_date   | employee_id | department_id | dept_avg_salary |
+------+-------------+--------+------------+-------------+---------------+-----------------+
|    1 |           1 |   9000 | 2017-03-31 |           1 |             1 |       9000.0000 |
|    2 |           2 |   6000 | 2017-03-31 |           2 |             2 |       8000.0000 |
|    4 |           1 |   7000 | 2017-02-28 |           1 |             1 |       7000.0000 |
|    5 |           2 |   6000 | 2017-02-28 |           2 |             2 |       7000.0000 |
+------+-------------+--------+------------+-------------+---------------+-----------------+

```

然后把这两个表连接起来,
```sql
SELECT * 
FROM (
	SELECT DATE_FORMAT(pay_date, '%Y-%m') AS pay_month, AVG(amount) AS `avg_salary`
	FROM salary AS s JOIN employee AS e
	ON s.employee_id = e.employee_id
	GROUP BY pay_month 
) AS A
JOIN
(
	SELECT e.department_id, DATE_FORMAT(pay_date, '%Y-%m') AS pay_month, AVG(amount) AS `dept_avg_salary`
	FROM salary AS s JOIN employee AS e 
	ON s.employee_id = e.employee_id
	GROUP BY pay_month, e.department_id
) AS B
ON A.pay_month = B.pay_month
ORDER BY B.pay_month DESC, B.department_id;
```
得到结果：
```
+-----------+------------+---------------+-----------+-----------------+
| pay_month | avg_salary | department_id | pay_month | dept_avg_salary |
+-----------+------------+---------------+-----------+-----------------+
| 2017-03   |  8333.3333 |             1 | 2017-03   |       9000.0000 |
| 2017-03   |  8333.3333 |             2 | 2017-03   |       8000.0000 |
| 2017-02   |  7000.0000 |             1 | 2017-02   |       7000.0000 |
| 2017-02   |  7000.0000 |             2 | 2017-02   |       7000.0000 |
+-----------+------------+---------------+-----------+-----------------+
```
最后，对这张表做比较，使用CASE WHEN语句来实现高于，低于，等于的判断。

通过代码：

```sql
SELECT B.pay_month,
	   B.department_id,
       CASE
			WHEN B.dept_avg_salary > A.avg_salary THEN 'higher'
			WHEN B.dept_avg_salary < A.avg_salary THEN 'lower'
			ELSE 'same'
        END AS 'comparison'

FROM 
(
	SELECT DATE_FORMAT(pay_date, '%Y-%m') AS pay_month, AVG(amount) AS `avg_salary`
	FROM salary AS s JOIN employee AS e
	ON s.employee_id = e.employee_id
	GROUP BY pay_month 
) AS A
JOIN
(
	SELECT e.department_id, DATE_FORMAT(pay_date, '%Y-%m') AS pay_month, AVG(amount) AS `dept_avg_salary`
	FROM salary AS s JOIN employee AS e 
	ON s.employee_id = e.employee_id
	GROUP BY pay_month, e.department_id
) AS B
ON A.pay_month = B.pay_month
ORDER BY B.pay_month DESC, B.department_id;

```

###	618	Students Report By Geography 学生地理信息报告

题目描述：
```
A U.S graduate school has students from Asia, Europe and America. The students' location information are stored in table student as below.

| name   | continent |
|--------|-----------|
| Jack   | America   |
| Pascal | Europe    |
| Xi     | Asia      |
| Jane   | America   |

Pivot the continent column in this table so that each name is sorted alphabetically and displayed underneath its corresponding continent. The output headers should be America, Asia and Europe respectively. 
It is guaranteed that the student number from America is no less than either Asia or Europe.

For the sample input, the output is:

| America | Asia | Europe |
|---------|------|--------|
| Jack    | Xi   | Pascal |
| Jane    |      |        |
 
Follow-up: If it is unknown which continent has the most students, can you write a query to generate the student report?

```

解题思路：这个是行转列问题，但是我没有思路怎么做。。看网上的方法是这样的

第一种思路，使用自定义变量，
```sql
SELECT @am := @am + 1 AS row_id, name AS America
FROM student, (SELECT @am := 0) AS init
WHERE continent = 'America'
ORDER BY name;
```
得到结果如下：
```
+--------+---------+
| row_id | America |
+--------+---------+
|      1 | Jack    |
|      2 | Jane    |
+--------+---------+
```
类似的，得到Asia和Europe地区的，然后将这三张表连接起来

通过代码：
```sql
SELECT a.name AS America, b.name AS Asia, c.name AS Europe
FROM (
    SELECT @r1 := @r1 + 1 AS id, name 
    FROM student, (SELECT @r1 := 0) init 
    WHERE continent = 'America' 
    ORDER BY name
) a
LEFT JOIN (
    SELECT @r2 := @r2 + 1 AS id, name 
    FROM student, (SELECT @r2 := 0) init 
    WHERE continent = 'Asia' 
    ORDER BY name
) b
ON a.id = b.id
LEFT JOIN (
    SELECT @r3 := @r3 + 1 AS id, name 
    FROM student, (SELECT @r3 := 0) init 
    WHERE continent = 'Europe' 
    ORDER BY name
) c
ON a.id = c.id
OR b.id = c.id;

```

第二种思路，使用窗口函数。
```sql
SELECT America, Asia, Europe
FROM(
    SELECT continentorder,
    MAX(CASE WHEN continent = 'America' THEN name END )AS America,
    MAX(CASE WHEN continent = 'Europe' THEN name END )AS Europe,
    MAX(CASE WHEN continent = 'Asia' THEN name END )AS Asia
    FROM (
        SELECT *,
        ROW_NUMBER()OVER(PARTITION BY continent ORDER BY name) AS continentorder
        FROM student
    ) AS SOURCE
    GROUP BY continentorder
)temp;

```

### 1097 Game Play Analysis V

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
 

We define the install date of a player to be the first login day of that player.

We also define day 1 retention of some date X to be the number of players whose install date is X and they logged back in on the day right after X, divided by the number of players whose install date is X, rounded to 2 decimal places.

Write an SQL query that reports for each install date, the number of players that installed the game on that day and the day 1 retention.

The query result format is in the following example:

Activity table:
+-----------+-----------+------------+--------------+
| player_id | device_id | event_date | games_played |
+-----------+-----------+------------+--------------+
| 1         | 2         | 2016-03-01 | 5            |
| 1         | 2         | 2016-03-02 | 6            |
| 2         | 3         | 2017-06-25 | 1            |
| 3         | 1         | 2016-03-01 | 0            |
| 3         | 4         | 2016-07-03 | 5            |
+-----------+-----------+------------+--------------+

Result table:
+------------+----------+----------------+
| install_dt | installs | Day1_retention |
+------------+----------+----------------+
| 2016-03-01 | 2        | 0.50           |
| 2017-06-25 | 1        | 0.00           |
+------------+----------+----------------+
Player 1 and 3 installed the game on 2016-03-01 but only player 1 logged back in on 2016-03-02 so the day 1 retention of 2016-03-01 is 1 / 2 = 0.50
Player 2 installed the game on 2017-06-25 but didn't log back in on 2017-06-26 so the day 1 retention of 2017-06-25 is 0 / 1 = 0.00

```

解题思路：找出每个玩家的安装日期，以及安装日期后的一日留存。

首先找出每个玩家的安装日期，即第一次登陆的日期，对玩家分组，求每组的最小日期。

```sql
SELECT player_id, MIN(event_date) AS 'install_dt'
FROM Activity
GROUP BY player_id;
```
得到每个玩家的按照日期：
```
+-----------+------------+
| player_id | install_dt |
+-----------+------------+
|         1 | 2016-03-01 |
|         2 | 2017-06-25 |
|         3 | 2016-03-01 |
+-----------+------------+
```
然后将这个表和原表连接，统计每个玩家第二天登陆的情况，因为存在第二天玩家没有登陆，因此，使用左连接
```sql

SELECT *
FROM (
        SELECT player_id, MIN(event_date) AS 'install_dt'
        FROM Activity
        GROUP BY player_id
    ) AS A 
LEFT JOIN Activity AS B 
ON A.player_id = B.player_id
AND B.event_date = DATE_ADD(A.install_dt, INTERVAL 1 DAY);
```
得到结果如下：
```
+-----------+------------+-----------+-----------+------------+--------------+
| player_id | install_dt | player_id | device_id | event_date | games_played |
+-----------+------------+-----------+-----------+------------+--------------+
|         1 | 2016-03-01 |         1 |         2 | 2016-03-02 |            6 |
|         2 | 2017-06-25 |      NULL |      NULL | NULL       |         NULL |
|         3 | 2016-03-01 |      NULL |      NULL | NULL       |         NULL |
+-----------+------------+-----------+-----------+------------+--------------+
```
有了这个结果后，计算一日留存率，即首日安装后第二天又登陆的玩家 / 首日安装的所有玩家

通过代码：

```sql
SELECT install_dt, COUNT(player_id) AS installs,
	   ROUND( COUNT(next_day) / COUNT(player_id), 2 ) AS Day1_retention
FROM (
	SELECT A.player_id, A.install_dt, B.event_date AS 'next_day'
	FROM (
			SELECT player_id, MIN(event_date) AS 'install_dt'
			FROM Activity
			GROUP BY player_id
		) AS A 
	LEFT JOIN Activity AS B 
	ON A.player_id = B.player_id
	AND B.event_date = DATE_ADD(A.install_dt,INTERVAL 1 DAY)
) AS t
GROUP BY install_dt;
```

### 1127 User Purchase Platform 

题目描述：
```
Table: Spending

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| user_id     | int     |
| spend_date  | date    |
| platform    | enum    | 
| amount      | int     |
+-------------+---------+
The table logs the spendings history of users that make purchases from an online shopping website which has a desktop and a mobile application.
(user_id, spend_date, platform) is the primary key of this table.
The platform column is an ENUM type of ('desktop', 'mobile').
Write an SQL query to find the total number of users and the total amount spent using mobile only, desktop only and both mobile and desktop together for each date.

The query result format is in the following example:

Spending table:
+---------+------------+----------+--------+
| user_id | spend_date | platform | amount |
+---------+------------+----------+--------+
| 1       | 2019-07-01 | mobile   | 100    |
| 1       | 2019-07-01 | desktop  | 100    |
| 2       | 2019-07-01 | mobile   | 100    |
| 2       | 2019-07-02 | mobile   | 100    |
| 3       | 2019-07-01 | desktop  | 100    |
| 3       | 2019-07-02 | desktop  | 100    |
+---------+------------+----------+--------+

Result table:
+------------+----------+--------------+-------------+
| spend_date | platform | total_amount | total_users |
+------------+----------+--------------+-------------+
| 2019-07-01 | desktop  | 100          | 1           |
| 2019-07-01 | mobile   | 100          | 1           |
| 2019-07-01 | both     | 200          | 1           |
| 2019-07-02 | desktop  | 100          | 1           |
| 2019-07-02 | mobile   | 100          | 1           |
| 2019-07-02 | both     | 0            | 0           |
+------------+----------+--------------+-------------+ 
On 2019-07-01, user 1 purchased using both desktop and mobile, user 2 purchased using mobile only and user 3 purchased using desktop only.
On 2019-07-02, user 2 purchased using mobile only,  user 3 purchased using desktop only and no one purchased using both platforms.

```

解题思路：

首先按照spend_date和user_id分组，统计平台信息，如果两个平台都有，就设为both
```sql
SELECT 
        spend_date,
        user_id,
        (CASE COUNT(DISTINCT platform)
              WHEN 1 THEN platform
              WHEN 2 THEN 'both'
         END) AS platform,
         SUM(amount) AS amount
FROM spending
GROUP BY spend_date, user_id;
```
得到结果如下：
```
+------------+---------+----------+--------+
| spend_date | user_id | platform | amount |
+------------+---------+----------+--------+
| 2019-07-01 |       1 | both     |    200 |
| 2019-07-01 |       2 | mobile   |    100 |
| 2019-07-01 |       3 | desktop  |    100 |
| 2019-07-02 |       2 | mobile   |    100 |
| 2019-07-02 |       3 | desktop  |    100 |
+------------+---------+----------+--------+

```
然后统计每天对应平台的总量和总用户
```sql 

SELECT spend_date,
       platform,
       SUM(amount) AS total_amount,
       COUNT(user_id) AS total_users
FROM (
    SELECT 
        spend_date,
        user_id,
        (CASE COUNT(DISTINCT platform)
              WHEN 1 THEN platform
              WHEN 2 THEN 'both'
         END) AS platform,
         SUM(amount) AS amount
    FROM spending
    GROUP BY spend_date, user_id
    ) AS b
GROUP BY spend_date, platform;
```
得到结果如下：
```
+------------+----------+--------------+-------------+
| spend_date | platform | total_amount | total_users |
+------------+----------+--------------+-------------+
| 2019-07-01 | both     |          200 |           1 |
| 2019-07-01 | desktop  |          100 |           1 |
| 2019-07-01 | mobile   |          100 |           1 |
| 2019-07-02 | desktop  |          100 |           1 |
| 2019-07-02 | mobile   |          100 |           1 |
+------------+----------+--------------+-------------+

```
这个结果和题目中给出的结果表还差对7-2日both结果的统计，因此做出来一个如下的表。

```sql
SELECT 'desktop' AS platform UNION
SELECT 'mobile' AS platform UNION
SELECT 'both' AS platform;

```
得到结果：
```
+----------+
| platform |
+----------+
| desktop  |
| mobile   |
| both     |
+----------+
```
连接表：
```sql
SELECT DISTINCT(spend_date), a.platform   
FROM Spending JOIN
    (   SELECT 'desktop' AS platform UNION
        SELECT 'mobile' AS platform UNION
        SELECT 'both' AS platform
    ) AS a 
```
得到结果：
```
+------------+----------+
| spend_date | platform |
+------------+----------+
| 2019-07-01 | desktop  |
| 2019-07-01 | mobile   |
| 2019-07-01 | both     |
| 2019-07-02 | desktop  |
| 2019-07-02 | mobile   |
| 2019-07-02 | both     |
+------------+----------+
```

再连接这两张大表：
```sql
SELECT *
FROM (
    SELECT DISTINCT(spend_date), a.platform   -- table aa
    FROM Spending JOIN
        (   SELECT 'desktop' AS platform UNION
            SELECT 'mobile' AS platform UNION
            SELECT 'both' AS platform
        ) AS a 
) AS ta
LEFT JOIN
(
    SELECT spend_date,
       platform,
       SUM(amount) AS total_amount,
       COUNT(user_id) AS total_users
    FROM (
        SELECT 
            spend_date,
            user_id,
            (CASE COUNT(DISTINCT platform)
                WHEN 1 THEN platform
                WHEN 2 THEN 'both'
            END) AS platform,
            SUM(amount) AS amount
        FROM spending
        GROUP BY spend_date, user_id
    ) AS b
    GROUP BY spend_date, platform
) as tb
ON ta.platform = tb.platform
AND ta.spend_date = tb.spend_date;
```
得到结果：
```
+------------+----------+------------+----------+--------------+-------------+
| spend_date | platform | spend_date | platform | total_amount | total_users |
+------------+----------+------------+----------+--------------+-------------+
| 2019-07-01 | both     | 2019-07-01 | both     |          200 |           1 |
| 2019-07-01 | desktop  | 2019-07-01 | desktop  |          100 |           1 |
| 2019-07-01 | mobile   | 2019-07-01 | mobile   |          100 |           1 |
| 2019-07-02 | desktop  | 2019-07-02 | desktop  |          100 |           1 |
| 2019-07-02 | mobile   | 2019-07-02 | mobile   |          100 |           1 |
| 2019-07-02 | both     | NULL       | NULL     |         NULL |        NULL |
+------------+----------+------------+----------+--------------+-------------+
```

最后，在这张表中，按照题目要求取出相应的值，其中null转化为0，

通过代码：

```sql
SELECT 
    ta.spend_date,
    ta.platform,
    COALESCE(tb.total_amount, 0) AS total_amount,
    COALESCE(tb.total_users, 0) AS total_users
FROM (
    SELECT DISTINCT(spend_date), a.platform   -- table aa
    FROM Spending JOIN
        (   SELECT 'desktop' AS platform UNION
            SELECT 'mobile' AS platform UNION
            SELECT 'both' AS platform
        ) AS a 
) AS ta
LEFT JOIN
(
    SELECT spend_date,
       platform,
       SUM(amount) AS total_amount,
       COUNT(user_id) AS total_users
    FROM (
        SELECT 
            spend_date,
            user_id,
            (CASE COUNT(DISTINCT platform)
                WHEN 1 THEN platform
                WHEN 2 THEN 'both'
            END) AS platform,
            SUM(amount) AS amount
        FROM spending
        GROUP BY spend_date, user_id
    ) AS b
    GROUP BY spend_date, platform
) as tb
ON ta.platform = tb.platform
AND ta.spend_date = tb.spend_date
ORDER BY spend_date, total_users DESC, total_amount;
```

### 1159.Market Analysis II

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
 

Write an SQL query to find for each user, whether the brand of the second item (by date) they sold is their favorite brand. If a user sold less than two items, report the answer for that user as no.

It is guaranteed that no seller sold more than one item on a day.

The query result format is in the following example:

Users table:
+---------+------------+----------------+
| user_id | join_date  | favorite_brand |
+---------+------------+----------------+
| 1       | 2019-01-01 | Lenovo         |
| 2       | 2019-02-09 | Samsung        |
| 3       | 2019-01-19 | LG             |
| 4       | 2019-05-21 | HP             |
+---------+------------+----------------+

Orders table:
+----------+------------+---------+----------+-----------+
| order_id | order_date | item_id | buyer_id | seller_id |
+----------+------------+---------+----------+-----------+
| 1        | 2019-08-01 | 4       | 1        | 2         |
| 2        | 2019-08-02 | 2       | 1        | 3         |
| 3        | 2019-08-03 | 3       | 2        | 3         |
| 4        | 2019-08-04 | 1       | 4        | 2         |
| 5        | 2019-08-04 | 1       | 3        | 4         |
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
+-----------+--------------------+
| seller_id | 2nd_item_fav_brand |
+-----------+--------------------+
| 1         | no                 |
| 2         | yes                |
| 3         | yes                |
| 4         | no                 |
+-----------+--------------------+

The answer for the user with id 1 is no because they sold nothing.
The answer for the users with id 2 and 3 is yes because the brands of their second sold items are their favorite brands.
The answer for the user with id 4 is no because the brand of their second sold item is not their favorite brand.

```

解题思路：

通过代码：

```sql
SELECT user_id AS seller_id, 
       IF(item_brand = favorite_brand, 'yes', 'no') AS 2nd_item_fav_brand 
FROM   (SELECT user_id, 
               favorite_brand, 
               (SELECT    item_id
                FROM      orders o 
                WHERE     user_id = o.seller_id 
                ORDER BY order_date limit 1, 1) AS item_id
        FROM   users) AS u
LEFT JOIN items AS i 
ON        u.item_id = i.item_id
ORDER BY seller_id;

```

### 1194.Tournament Winners

题目描述：
```
Table: Players

+-------------+-------+
| Column Name | Type  |
+-------------+-------+
| player_id   | int   |
| group_id    | int   |
+-------------+-------+
player_id is the primary key of this table.
Each row of this table indicates the group of each player.
Table: Matches

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| match_id      | int     |
| first_player  | int     |
| second_player | int     | 
| first_score   | int     |
| second_score  | int     |
+---------------+---------+
match_id is the primary key of this table.
Each row is a record of a match, first_player and second_player contain the player_id of each match.
first_score and second_score contain the number of points of the first_player and second_player respectively.
You may assume that, in each match, players belongs to the same group.
 

The winner in each group is the player who scored the maximum total points within the group. 
In the case of a tie, the lowest player_id wins.

Write an SQL query to find the winner in each group.

The query result format is in the following example:

Players table:
+-----------+------------+
| player_id | group_id   |
+-----------+------------+
| 15        | 1          |
| 25        | 1          |
| 30        | 1          |
| 45        | 1          |
| 10        | 2          |
| 35        | 2          |
| 50        | 2          |
| 20        | 3          |
| 40        | 3          |
+-----------+------------+

Matches table:
+------------+--------------+---------------+-------------+--------------+
| match_id   | first_player | second_player | first_score | second_score |
+------------+--------------+---------------+-------------+--------------+
| 1          | 15           | 45            | 3           | 0            |
| 2          | 30           | 25            | 1           | 2            |
| 3          | 30           | 15            | 2           | 0            |
| 4          | 40           | 20            | 5           | 2            |
| 5          | 35           | 50            | 1           | 1            |
+------------+--------------+---------------+-------------+--------------+

Result table:
+-----------+------------+
| group_id  | player_id  |
+-----------+------------+ 
| 1         | 15         |
| 2         | 35         |
| 3         | 40         |
+-----------+------------+

```

解题思路：本题的意思是每个运动员在5场比赛中获取的分数累加，得到累加和。然后每个运动员又分组，找出每组内累加和最高的运动员，如果累加和一样高，那选出player_id更小的。

首先找出每个运动员在5场比赛中各自的分数：

```sql
SELECT first_player AS player_id, first_score AS score
FROM Matches
UNION ALL
SELECT second_player AS player_id, second_score AS score
FROM Matches;

```
得到的结果如下：
```
+-----------+-------+
| player_id | score |
+-----------+-------+
|        15 |     3 |
|        30 |     1 |
|        30 |     2 |
|        40 |     5 |
|        35 |     1 |
|        45 |     0 |
|        25 |     2 |
|        15 |     0 |
|        20 |     2 |
|        50 |     1 |
+-----------+-------+
```

然后把这个表和运动员表连接，并对运动员id分组，求出每个运动员所有分数总和

```sql
SELECT 
	p.group_id, 
    ps.player_id, 
    SUM(ps.score) AS score
FROM Players AS p
INNER JOIN (
    SELECT first_player AS player_id, first_score AS score
    FROM Matches
    UNION ALL
    SELECT second_player AS player_id, second_score AS score
    FROM Matches
) AS ps
ON p.player_id = ps.player_id
GROUP BY ps.player_id
ORDER  BY group_id, 
		  score DESC, 
		  player_id;
```
得到结果如下：
```
+----------+-----------+-------+
| group_id | player_id | score |
+----------+-----------+-------+
|        1 |        15 |     3 |
|        1 |        30 |     3 |
|        1 |        25 |     2 |
|        1 |        45 |     0 |
|        2 |        35 |     1 |
|        2 |        50 |     1 |
|        3 |        40 |     5 |
|        3 |        20 |     2 |
+----------+-----------+-------+
```
最后，对这个表中的group_id分组，找出每个组内分数最高的，如果分数相同，找出player_id更小的。

通过代码：

```sql
SELECT 
    group_id,
    player_id
FROM (
        SELECT 
            p.group_id, 
            ps.player_id, 
            SUM(ps.score) AS score
        FROM Players AS p
        INNER JOIN (
            SELECT first_player AS player_id, first_score AS score
            FROM Matches
            UNION ALL
            SELECT second_player AS player_id, second_score AS score
            FROM Matches
        ) AS ps
        ON p.player_id = ps.player_id
        GROUP BY ps.player_id
        ORDER BY group_id, 
                score DESC, 
                player_id
) AS top_scores
GROUP BY group_id;
```

### 1225.Report Contiguous Dates

题目描述：
```
Table: Failed

+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| fail_date    | date    |
+--------------+---------+
Primary key for this table is fail_date.
Failed table contains the days of failed tasks.
Table: Succeeded

+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| success_date | date    |
+--------------+---------+
Primary key for this table is success_date.
Succeeded table contains the days of succeeded tasks.
 

A system is running one task every day. Every task is independent of the previous tasks. The tasks can fail or succeed.

Write an SQL query to generate a report of period_state for each continuous interval of days in the period from 2019-01-01 to 2019-12-31.

period_state is 'failed' if tasks in this interval failed or 'succeeded' if tasks in this interval succeeded. Interval of days are retrieved as start_date and end_date.

Order result by start_date.

The query result format is in the following example:

Failed table:
+-------------------+
| fail_date         |
+-------------------+
| 2018-12-28        |
| 2018-12-29        |
| 2019-01-04        |
| 2019-01-05        |
+-------------------+

Succeeded table:
+-------------------+
| success_date      |
+-------------------+
| 2018-12-30        |
| 2018-12-31        |
| 2019-01-01        |
| 2019-01-02        |
| 2019-01-03        |
| 2019-01-06        |
+-------------------+


Result table:
+--------------+--------------+--------------+
| period_state | start_date   | end_date     |
+--------------+--------------+--------------+
| succeeded    | 2019-01-01   | 2019-01-03   |
| failed       | 2019-01-04   | 2019-01-05   |
| succeeded    | 2019-01-06   | 2019-01-06   |
+--------------+--------------+--------------+

The report ignored the system state in 2018 as we care about the system in the period 2019-01-01 to 2019-12-31.
From 2019-01-01 to 2019-01-03 all tasks succeeded and the system state was "succeeded".
From 2019-01-04 to 2019-01-05 all tasks failed and system state was "failed".
From 2019-01-06 to 2019-01-06 all tasks succeeded and system state was "succeeded".

```

解题思路：Failed 和 Succeeded表，用来记录一个每日定时跑的系统任务的失败和成功。要求返回一张结果表，按顺序展示该任务失败和成功的连续时间段以及起止时间。

首先找出在2019年成功和失败的所有任务：
```sql
SELECT *
FROM (
    SELECT 
        fail_date AS date,
        'failed' AS state
    FROM Failed
    UNION ALL
    SELECT 
        success_date AS date,
        'succeeded' AS state
    FROM Succeeded
) AS a
WHERE date BETWEEN '2019-01-01' AND '2019-12-31' 
ORDER BY date;
```

得到结果：
```
+------------+-----------+
| date       | state     |
+------------+-----------+
| 2019-01-01 | succeeded |
| 2019-01-02 | succeeded |
| 2019-01-03 | succeeded |
| 2019-01-04 | failed    |
| 2019-01-05 | failed    |
| 2019-01-06 | succeeded |
+------------+-----------+
```

然后在这个表中，继续增加两列：
```sql
SELECT *
FROM (
	SELECT *
	FROM (
        SELECT fail_date AS date,
               'failed' AS state
        FROM Failed
        UNION ALL
        SELECT success_date AS date,
               'succeeded' AS state
        FROM Succeeded
	) AS a
	WHERE date BETWEEN '2019-01-01' AND '2019-12-31' 
	ORDER BY date
) AS b, 
(
SELECT @rank := 0,
	   @prev := "unkonwn"

) AS c;
```
得到结果：
```
+------------+-----------+------------+--------------------+
| date       | state     | @rank := 0 | @prev := "unkonwn" |
+------------+-----------+------------+--------------------+
| 2019-01-01 | succeeded |          0 | unkonwn            |
| 2019-01-02 | succeeded |          0 | unkonwn            |
| 2019-01-03 | succeeded |          0 | unkonwn            |
| 2019-01-04 | failed    |          0 | unkonwn            |
| 2019-01-05 | failed    |          0 | unkonwn            |
| 2019-01-06 | succeeded |          0 | unkonwn            |
+------------+-----------+------------+--------------------+
```
然后对rank和prev更新，
```sql
SELECT 
	state,
    date,
    @rank := CASE 
				WHEN @prev = state THEN @rank
                ELSE @rank + 1
			 END AS rank,
	@prev := state AS prev
FROM (
	SELECT *
	FROM (
        SELECT fail_date AS date,
               'failed' AS state
        FROM Failed
        UNION ALL
        SELECT success_date AS date,
               'succeeded' AS state
        FROM Succeeded
	) AS a
	WHERE date BETWEEN '2019-01-01' AND '2019-12-31' 
	ORDER BY date
) AS b, 
(
SELECT @rank := 0,
	   @prev := "unkonwn"

) AS c;
```
得到结果：
```
+-----------+------------+------+-----------+
| state     | date       | rank | prev      |
+-----------+------------+------+-----------+
| succeeded | 2019-01-01 |    1 | succeeded |
| succeeded | 2019-01-02 |    1 | succeeded |
| succeeded | 2019-01-03 |    1 | succeeded |
| failed    | 2019-01-04 |    2 | failed    |
| failed    | 2019-01-05 |    2 | failed    |
| succeeded | 2019-01-06 |    3 | succeeded |
+-----------+------------+------+-----------+
```
最后，对rank分组，即对任务状态分组，分别求每组date的最小值和最大值就是该组任务的起止时间

通过代码：

```sql
SELECT 
    state     AS period_state,
    MIN(date) AS start_date,
    MAX(date) AS end_date
FROM (
    SELECT 
        state,
        date,
        @rank := CASE 
                    WHEN @prev = state THEN @rank
                    ELSE @rank + 1
                END AS rank,
        @prev := state AS prev
    FROM (
        SELECT *
        FROM (
            SELECT fail_date AS date,
                'failed' AS state
            FROM Failed
            UNION ALL
            SELECT success_date AS date,
                'succeeded' AS state
            FROM Succeeded
        ) AS a
        WHERE date BETWEEN '2019-01-01' AND '2019-12-31' 
        ORDER BY date
    ) AS b, 
    (
    SELECT @rank := 0,
        @prev := "unkonwn"

    ) AS c
) AS d
GROUP BY d.rank
ORDER BY start_date;
```
