

本文包含LeetCode中easy难度的sql练习题的解题思路和通过代码，关于题目描述可以查看[leetcode原网站](https://leetcode.com/problemset/database/?difficulty=Easy)，或者[leetcode中文网站](https://leetcode-cn.com/problemset/database/?difficulty=%E7%AE%80%E5%8D%95)

关于带锁的部分练习，由于博主没有开会员，所以没有在LeetCode网站上测试过，参考了别的博客写的。另外题目编号1113,1141,1142,1148,1173这几道题还没写出来。

<!--more-->

### 175. Combine Two Tables组合两个表 

题目描述：https://leetcode.com/problems/combine-two-tables/

思路：题中给出的条件是无论 person 是否有地址信息，都需要基于上述两表提供 Person 的以下信息。也就是说以Person表为主表，主表中有的人有Address表中的地址信息，有的人没有。因此使用`LEFT JOIN`

MySQL通过代码：
```sql
SELECT P.FirstName, P.LastName, A.City, A.State
FROM Person AS P LEFT JOIN Address AS A
ON P.PersonId = A.PersonId;
```

### 176. Second Highest Salary	第二高的薪水
题目描述： https://leetcode.com/problems/second-highest-salary/

我最开始的思路是:先将薪水最高的找出来排除掉，然后再在剩下的中找出最高的，那就是第二高的，另外再加上CASE WHEN判断第二高是否为空，
第一次代码：

```sql
SELECT 
    CASE WHEN MAX(Salary) IS NOT NULL 
    THEN Salary 
    ELSE NULL 
    END 
FROM Employee 
WHERE Salary < (
    SELECT MAX(Salary)
    FROM Employee
);

```
但是这样写报错不能通过，我又检查好多遍，，发现了两个错误，一个是`THEN Salary `如果第二最大不是空值的话应该返回第二最大值的，但是我写的还是Salary。第二个错误是没有仔细审题，题目要求返回的第二高命名为`SecondHighestSalary`，但是我没有命名。

正确通过代码：
```sql
SELECT 
    CASE WHEN MAX(Salary) IS NOT NULL 
    THEN MAX(Salary)
    ELSE NULL 
    END  AS SecondHighestSalary
FROM Employee 
WHERE Salary < (
    SELECT MAX(Salary)
    FROM Employee
);

```
再看关于题目讨论时候，发现CASE WHEN是多余的，可以省去，

简化后的通过代码：
```sql
SELECT 
    MAX(Salary) AS SecondHighestSalary
FROM Employee 
WHERE Salary < (
    SELECT MAX(Salary)
    FROM Employee
);

```
但是这个思路如果题目换成求第4高，第5高的话，那就再换个思路了。

第二种思路：先把所有工资降序排序，并用DISTINCT去重，排除第1，第2高的工资有并列的情况；然后使用LIMIT和OFFSET语句取出第二高薪水的。关于如果第二是空的返回NULL，使用IFNULL函数判断。

第二种思路通过代码
```sql
SELECT IFNULL(
    (SELECT DISTINCT salary FROM Employee
     ORDER BY salary DESC
     LIMIT 1 OFFSET 1
    ), NULL) AS SecondHighestSalary
```
而且也可以扩展，比如换成取第四高薪水的：
```sql
SELECT IFNULL(
    (SELECT DISTINCT salary FROM Employee
     ORDER BY salary DESC
     LIMIT 1 OFFSET 3
    ), NULL) AS SecondHighestSalary
```

这里用到一个我以前不常用的知识点：
> IFNULL() 函数语法格式为：IFNULL(expression, alt_value)。用于判断第一个表达式是否为 NULL，如果为 NULL 则返回第二个参数的值，如果不为 NULL 则返回第一个参数的值。

IFNULL() 函数测试例子：

```sql
SELECT IFNULL(NULL, "RUNOOB");
-- 以上实例输出结果为：RUNOOB

SELECT IFNULL("Hello", "RUNOOB");
-- 以上实例输出结果为：Hello

```

### 181. Employees Earning More Than Their Managers超过经理收入的员工 
题目描述：https://leetcode.com/problems/employees-earning-more-than-their-managers/

思路：使用内连接，

通过代码：
```sql
SELECT E1.Name AS Employee
FROM Employee AS E1 INNER JOIN Employee AS E2
ON E1.ManagerId = E2.Id
WHERE E1.Salary > E2.Salary;

```

### 182. Duplicate Emails查找重复的电子邮箱 
题目描述：https://leetcode.com/problems/duplicate-emails/

思路：使用GROUP BY对邮箱分组，如果邮箱重复了那么该邮箱对应的Id肯定>1，使用HAVING过滤。

通过代码：

```sql
SELECT Email
FROM Person
GROUP BY Email
HAVING COUNT(Id) > 1;

```

### 183. Customers Who Never Order	从不订购的客户
题目描述：https://leetcode.com/problems/customers-who-never-order/

思路：以客户表Customers为主表，左联结订单表Orders，联结条件设为客户表中的Id与订单表中的CustomerId相同，联结后如果客户表中有客户没有下过单，那么订单表中的Id就是空的，以此筛选出符合条件的。

通过代码：

```sql
SELECT C.Name AS Customers
FROM Customers AS C LEFT JOIN Orders AS O
ON C.Id = O.CustomerId
WHERE O.Id IS NULL;

```

第二种思路：选出已经下过单的用户，使用NOT EXISTS将这些订购过的排除，得到的就是没有下过单的

```sql
select name AS Customers 
from Customers AS C 
where not exists (
    select 1 from Orders AS O 
    where O.customerid=C.id
);

```

EXISTS的作用是判断：如果在订单表中下过单，就返回真。
然后使用NOT EXISTS取反，取反后的作用是判断：如果在订单表中没有下过单，就返回真。

这里解释下为什么使用`SELECT 1`，`SELECT 1`存在记录的话查询结果就会全部被1替代，而`SELECT *` 会返回所有的字段。`SELECT 1`与`SELECT *`或者`select 某个字段`从功能上来说是等效的，都是用来查询是否有记录。但是从效率上来说，`SELECT 1`语句的运行效率更高。


### 196. Delete Duplicate Emails删除重复的电子邮箱 
题目描述：https://leetcode.com/problems/delete-duplicate-emails/

最开始思路：先对Email分组，分组后同一Email组中取Id最小的，然后将该分组中其他的Id都删掉，
代码如下
```sql
DELETE FROM Person WHERE Id NOT IN (
    SELECT MIN(Id)
    FROM Person
    GROUP BY Email
);
```

但是这样写出错了，提示：You can't specify target table 'Person' for update in FROM clause
意思是：不能先select出同一表中的某些值，再update或delete这个表中的这些值(在同一语句中)

该错误解决方法： 嵌套一个子查询，将查询结果作为临时表，然后从临时表里查询Id，将其作为NOT IN的查询集合，然后再删除。

通过代码：
```sql
DELETE FROM Person 
WHERE Id NOT IN (
    SELECT Id FROM (
        SELECT MIN(Id) AS Id
        FROM Person
        GROUP BY Email
    ) AS min_id  -- 此处需使用别名，否则会发生报错
);
```
需要注意的是，进行嵌套查询的时候子查询出来的的结果是作为一个派生表来进行上一级的查询的，所以子查询的结果必须要有一个别名`min_id`，否则会提示报错：`Every derived table must have its own alias`

第二种思路： 将Person表与自身联结，设过滤条件为两个表中的Email相同，但p1表中的Id>p2表中的Id

通过代码：

```sql
DELETE p1 FROM Person AS p1, Person AS p2
WHERE p1.Email = p2.Email AND p1.Id > p2.Id
```
需要注意的是，`DELETE p1 FROM `中的p1是不能省略的，需要指定删除p1还是p2表。
另外当delete语句中使用表的别名时，要在delete和from间加上删除表的别名，否则会报错：You have an error in your SQL syntax;

### 197. Rising Temperature上升的温度 
题目描述：https://leetcode.com/problems/rising-temperature/

开始的错误思路：今天的日期 = 昨天的日期+1

错误代码：
```
SELECT W2.Id AS Id
FROM Weather AS W1, Weather AS W2
WHERE W2.Id = W1.Id + 1 AND W2.Temperature > W1.Temperature
```
这种写法报错是因为要考虑到日期为月末的情况，如果是31号，那么+1就是32号了，而不是次月1日。

正确思路：用datediff()函数来实现判断今天和昨天

通过代码：
```sql
SELECT W1.Id AS Id
FROM Weather AS W1 INNER JOIN Weather AS W2 
ON DATEDIFF(W1.RecordDate, W2.RecordDate) = 1  -- W1为今天的温度，W2为昨天的温度。
WHERE W1.Temperature > W2.Temperature;
```
关于datediff()函数的知识点：
> DATEDIFF(expr1,expr2)
> DATEDIFF() returns expr1 − expr2 expressed as a value in days from one date to the other. expr1 and expr2 are date or date-and-time expressions. Only the date parts of the values are used in the calculation.
```sql
mysql> SELECT DATEDIFF('2007-12-31 23:59:59','2007-12-30');
        -> 1
mysql> SELECT DATEDIFF('2010-11-30 23:59:59','2010-12-31');
        -> -31
```

### 511. Game Play Analysis I 	游戏玩法分析 I
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
Each row is a record of a player who logged in and played 
a number of games (possibly 0) before logging out on some day using some device.

Write an SQL query that reports the first login date for each player.

The query result format is in the following example:

Activity table:
+-----------+-----------+------------+--------------+
| player_id | device_id | event_date | games_played |
+-----------+-----------+------------+--------------+
| 1         | 2         | 2016-03-01 | 5            |
| 1         | 2         | 2016-05-02 | 6            |
| 2         | 3         | 2017-06-25 | 1            |
| 3         | 1         | 2016-03-02 | 0            |
| 3         | 4         | 2018-07-03 | 5            |
+-----------+-----------+------------+--------------+

Result table:
+-----------+-------------+
| player_id | first_login |
+-----------+-------------+
| 1         | 2016-03-01  |
| 2         | 2017-06-25  |
| 3         | 2016-03-02  |
+-----------+-------------+
```

思路：题目要求找出每个玩家第一次登录的日期，那么可以把每个玩家分组，每组内是该玩家所有的登录日期，然后取最小的日期，就是该玩家第一次登录的日期

通过代码：

```sql
SELECT player_id, MIN(event_date) AS first_login
FROM Activity
GROUP BY player_id;

```

### 512. Game Play Analysis II 游戏玩法分析 II

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

Each row is a record of a player who logged in and played a number of 
games (possibly 0) before logging out on some day using some device.

Write a SQL query that reports the device that is first logged in for each player.

The query result format is in the following example:

Activity table:
+-----------+-----------+------------+--------------+
| player_id | device_id | event_date | games_played |
+-----------+-----------+------------+--------------+
| 1         | 2         | 2016-03-01 | 5            |
| 1         | 2         | 2016-05-02 | 6            |
| 2         | 3         | 2017-06-25 | 1            |
| 3         | 1         | 2016-03-02 | 0            |
| 3         | 4         | 2018-07-03 | 5            |
+-----------+-----------+------------+--------------+

Result table:
+-----------+-----------+
| player_id | device_id |
+-----------+-----------+
| 1         | 2         |
| 2         | 3         |
| 3         | 1         |
+-----------+-----------+
```

思路：题目要求找出每个玩家最早登录的设备号，先对玩家分组，找出玩家最早的登录日期，通过最早日期筛选出登录的最早设备。

通过代码：

```sql
SELECT A.player_id, A.device_id
FROM Activity AS A
WHERE (A.player_id, A.event_date) IN (
    SELECT player_id, MIN(event_date) AS min_date
    FROM Activity
    GROUP BY player_id;
)

```
或者也可以用内连接的方式：

```sql
SELECT A.player_id, A.device_id
FROM Activity AS A 
INNER JOIN
(
    SELECT player_id, MIN(event_date) AS min_date
    FROM Activity
    GROUP BY player_id;
) AS B
ON A.player_id = B.player_id AND A.event_date = B.min_date

```

### 577. Employee Bonus  员工奖金
题目描述：
```
Select all employee''s name and bonus whose bonus is < 1000.

Table:Employee
+-------+--------+-----------+--------+
| empId |  name  | supervisor| salary |
+-------+--------+-----------+--------+
|   1   | John   |  3        | 1000   |
|   2   | Dan    |  3        | 2000   |
|   3   | Brad   |  null     | 4000   |
|   4   | Thomas |  3        | 4000   |
+-------+--------+-----------+--------+
empId is the primary key column for this table.

Table: Bonus
+-------+-------+
| empId | bonus |
+-------+-------+
| 2     | 500   |
| 4     | 2000  |
+-------+-------+
empId is the primary key column for this table.

Example ouput:
+-------+-------+
| name  | bonus |
+-------+-------+
| John  | null  |
| Dan   | 500   |
| Brad  | null  |
+-------+-------+
```

思路：题目要求找出奖金少于1000的员工，从给出的示例输出可知，少于1000包含两种：一种是有奖金，但不到1000，比如500；另一种是没有奖金null，因此，在设过滤条件时这两者应该是OR的关系。

通过代码：

```sql
SELECT E.name, B.bonus
FROM Employee AS E LEFT JOIN Bonus AS B
ON E.empId = B.empId
WHERE B.bonus IS NULL OR B.bonus < 1000
```

### 584. Find Customer Referee 	寻找用户推荐人 
题目描述：
```
Given a table customer holding customers information and the referee.

customer
+------+------+-----------+
| id   | name | referee_id|
+------+------+-----------+
|    1 | Will |      NULL |
|    2 | Jane |      NULL |
|    3 | Alex |         2 |
|    4 | Bill |      NULL |
|    5 | Zack |         1 |
|    6 | Mark |         2 |
+------+------+-----------+

Write a query to return the list of customers NOT referred by the person with id '2'. 
Include those has no referee.

For the sample data above, the result is:
+------+
| name |
+------+
| Will |
| Jane |
| Bill |
| Zack |
+------+
```

思路：注意没有推荐人的情况，过滤条件有两种：推荐人id不是2，或者，没有推荐人

通过代码：

```sql
SELECT name
FROM customer
WHERE referee_id != 2 OR referee_id IS NULL;
```

### 586. Customer Placing the Largest Number of Orders 订单最多的客户
题目描述：
```
Query the customer_number from the orders table for the customer who has placed the largest number of orders.

It is guaranteed that exactly one customer will have placed more orders than any other customer.

The orders table is defined as follows:

| Column            | Type      |
|-------------------|-----------|
| order_number (PK) | int       |
| customer_number   | int       |
| order_date        | date      |
| required_date     | date      |
| shipped_date      | date      |
| status            | char(15)  |
| comment           | char(200) |

Sample Input
| order_number | customer_number | order_date | required_date | shipped_date | status | comment |
|--------------|-----------------|------------|---------------|--------------|--------|---------|
| 1            | 1               | 2017-04-09 | 2017-04-13    | 2017-04-12   | Closed |         |
| 2            | 2               | 2017-04-15 | 2017-04-20    | 2017-04-18   | Closed |         |
| 3            | 3               | 2017-04-16 | 2017-04-25    | 2017-04-20   | Closed |         |
| 4            | 3               | 2017-04-18 | 2017-04-28    | 2017-04-25   | Closed |         |

Sample Output
| customer_number |
|-----------------|
| 3               |


Explanation
The customer with number '3' has two orders, which is greater than either customer '1' or '2' because each of them  only has one order. 

So the result is customer_number '3'.

Follow up: What if more than one customer have the largest number of orders, 
can you find all the customer_number in this case?

```

思路：题目要求查询 orders 表中下了最多订单的客户对应的 customer_number 。且假设只有一个客户的订单数比其他所有客户多。那么可以先对客户分组，然后计算每个客户的订单数量，把数量逆序排序，取第一个就是下单最多的客户。

通过代码：

```sql
SELECT customer_number
FROM orders
GROUP BY customer_number
ORDER BY COUNT(order_number) DESC
LIMIT 1 OFFSET 0;

```

进阶问题：如果最大订单数量的客户有多个，怎么把这些客户都找出来？比如：有n个客户，他们的订单量都是最大的订单量，怎么把这n个人的customer_number找出来？

思路：还是先把客户分组，计算每个客户的订单量，然后从这些订单量中找出最大的数量，然后在各组客户中设置分组条件：客户的订单数量等于最大的订单数量，这样就能选出拥有最大订单量的各个客户。

通过代码：
```sql
SELECT customer_number
FROM orders
GROUP BY customer_number
HAVING COUNT(*) = (   -- 最后设置分组条件：客户的订单数量等于最大的订单数量
    SELECT MAX(cnt)   -- 然后从这些订单量中找出最大的数量
    FROM (
        SELECT COUNT(*) AS cnt       -- 先把客户分组，计算每个客户的订单量
        FROM orders
        GROUP BY customer_number
    )
)

```
### 595. Big Countries 大的国家
题目描述：https://leetcode.com/problems/big-countries/

思路：注意单位是 million，百万。

通过代码：

```sql
SELECT name, population, area
FROM World
WHERE area > 3000000 OR population > 25000000;
```

### 596. Classes More Than 5 Students 超过5名学生的课 
题目描述：https://leetcode.com/problems/classes-more-than-5-students/

思路：对课程分组，查找某课程下学生数量>=5个人的。

没通过代码：

```sql
SELECT class
FROM courses
GROUP BY class
HAVING COUNT(student) >= 5;
```

看了下没通过的原因，测试的例子是：
```
{"headers": {"courses": ["student", "class"]}, "rows": {"courses": [["A", "Math"], ["B", "English"], ["C", "Math"], ["D", "Biology"], ["E", "Math"], ["F", "Math"], ["A", "Math"]]}}
```
发现例子中有重复的，两个["A", "Math"]，需要对学生去重，

通过代码：
```sql
SELECT class
FROM courses
GROUP BY class
HAVING COUNT( DISTINCT student) >= 5;
```

### 597. Friend Requests I: Overall Acceptance Rate 好友申请 I ：总体通过率 

题目描述：
```
In social network like Facebook or Twitter, people send friend requests and accept others requests as well. 
Now given two tables as below:

Table: friend_request
| sender_id | send_to_id |request_date|
|-----------|------------|------------|
| 1         | 2          | 2016_06-01 |
| 1         | 3          | 2016_06-01 |
| 1         | 4          | 2016_06-01 |
| 2         | 3          | 2016_06-02 |
| 3         | 4          | 2016-06-09 |


Table: request_accepted
| requester_id | accepter_id |accept_date |
|--------------|-------------|------------|
| 1            | 2           | 2016_06-03 |
| 1            | 3           | 2016-06-08 |
| 2            | 3           | 2016-06-08 |
| 3            | 4           | 2016-06-09 |
| 3            | 4           | 2016-06-10 |

Write a query to find the overall acceptance rate of requests rounded to 2 decimals, which is the number of acceptance divide the number of requests.

For the sample data above, your query should return the following result.
|accept_rate|
|-----------|
|       0.80|

Note:
    The accepted requests are not necessarily from the table friend_request. In this case, you just need to simply count the total accepted requests (no matter whether they are in the original requests), and divide it by the number of requests to get the acceptance rate.
    It is possible that a sender sends multiple requests to the same receiver, and a request could be accepted more than once. In this case, the ‘duplicated’ requests or acceptances are only counted once.
    If there is no requests at all, you should return 0.00 as the accept_rate.

Explanation: There are 4 unique accepted requests, and there are 5 requests in total. So the rate is 0.80.

Follow-up:
Can you write a query to return the accept rate but for every month?
How about the cumulative accept rate for every day?

```

思路：题目求好友请求的接受率，即接受请求的数量除以总请求数量，并保留2位小数。注意去重和没有请求的情况。

通过代码：

```sql
SELECT 
    ROUND( 
        IFNULL(
             -- 统计被接受的请求量，一个请求可能接受多次，但是统计时只算一次，因此去重
             (SELECT COUNT(*) FROM (SELECT DISTINCT requester_id, accepter_id FROM request_accepted) AS A)
             /    -- 接受率 = 被接受的请求的数量 / 总的请求量
             -- 统计总的请求量，一个人可能向同一人发送多次请求，只算一次，因此去重
             (SELECT COUNT(*) FROM (SELECT DISTINCT sender_id, send_to_id FROM friend_request) AS B)
        , 0)  -- 如果没有请求，返回0.00作为接受率
    , 2)   -- round()函数保留两位小数
) AS accept_rate;

```

**进阶问题，求出每个月的好友请求接受率和每天的好友请求接受率？**

### 603. Consecutive Available Seats 连续空余座位 
题目描述：https://leetcode.com/articles/consecutive-available-seats/

思路：找出的座位需要符合两个条件，一个是空余的，即`free=1`，另一个是要连续，连续指的是>=2个空余的座位，且seat_id是相邻的，相邻即两个id号之间的差为1。
那么可以将表自连接，首先找出空余的，然后找出座位id差1的，这个可以用`ABS(a.seat_id - b.seat_id) = 1`来判定，但是需要注意的是，可能产生的重复值，比如：

将表自连接后，对于id=4的座位，和id=3和id=5的座位相邻，在相邻条件判定的时候：`4-3=1,5-4=1`， 那么就会出现座位id为4的重复座位
```
seat_id	free	seat_id	free
4	1	3	1
3	1	4	1
5	1	4	1
4	1	5	1
```
因此，需要在最后对`seat_id`进行去重，然后在对id号排序。

通过代码：
```sql
SELECT DISTINCT a.seat_id
FROM cinema AS a JOIN cinema AS b
ON a.free = 1 AND b.free = 1 AND ABS(a.seat_id - b.seat_id) = 1
ORDER BY a.seat_id;
```

### 607. Sales Person 销售员
题目描述：https://leetcode.com/articles/sales-person/

思路：题目要求给出对’RED’公司没有销量的销售姓名，那么可以先找出对RED公司有销量的所有销售的姓名，然后使用NOT IN 排除掉这些人，剩下的就是对该公司没有销量的销售姓名。
在找对’RED’公司有销量的销售姓名时，需要将公司表company和订单表orders联结，并指定RED公司为过滤条件，找出销售员id。

通过代码：

```sql
SELECT s.name
FROM salesperson AS s
WHERE sales_id NOT IN (
    SELECT o.sales_id
    FROM orders AS o LEFT JOIN company AS c
    ON o.com_id = c.com_id
    WHERE c.name = 'RED'
);

```

### 610. 判断三角形
题目描述：https://leetcode.com/articles/triangle-judgement/

思路：一开始忘记了三角形的判定条件了。。查了下才知道任意两边之和大于第三边，然后使用CASE WHEN来判定，或者if()函数也可以

通过代码
```sql
SELECT x,y,z
    CASE 
        WHEN x + y > z AND x + z > y AND y + z > x THEN 'Yes'
        ELSE 'No'
    END AS 'triangle'
FROM triangle;
```
使用if()函数通过代码
```sql
SELECT x,y,z
    IF(x + y > z AND x + z > y AND y + z > x, 'Yes', 'No') AS 'triangle'
FROM triangle;
```

### 613. Shortest Distance in a Line 直线上的最近距离
题目描述：https://leetcode.com/articles/shortest-distance-in-a-line/

思路：开始是想到用自连接将point表连接的，但是对于连接条件on有点蒙，不知道怎么设，后来看了下解答，才注意到有个条件，每个点都是唯一的， point 表中没有重复记录。因此连接条件设为`p1.x != p2.x`。
连接完成后，有了所有可能的点对，先求出每两个点之间的距离，再用MIN()函数得到最小的距离。

通过代码：
```sql
SELECT MIN(ABS(p1.x-p2.x)) AS shortest
FROM point AS p1 INNER JOIN point AS p2
ON p1.x != p2.x
```

这种方法把每两个点之间的距离计算了两次，在讨论区看到第二种更好的解决方法：

```sql
SELECT MIN(p1.x - p2.x) AS shortest
FROM point AS p1 INNER JOIN point AS p2
ON p1.x > p2.x;
```
第二种方法通过`p1.x > p2.x`的连接条件，避免了重复计算，把效率提升了一倍。

### 619. Biggest Single Number	只出现一次的最大数字
题目描述：https://leetcode.com/articles/biggest-single-number/

思路：使用子查询找出只出现一次的数字，然后使用MAX找出这些数字中的最大值。

通过代码：

```sql

SELECT MAX(num) AS num
FROM (
    SELECT num
    FROM my_numbers
    GROUP BY num
    HAVING COUNT(num) = 1
) AS m;  -- 注意子查询必须命名别称

```

### 620. Not Boring Movies 	有趣的电影
题目描述：https://leetcode.com/problems/not-boring-movies/

思路：过滤条件一个是`description != 'boring'`，另一个是id为奇数，可以用`id % 2 = 1`判断奇数。最后根据rating逆序排序。

通过代码：

```sql
SELECT *
FROM cinema
WHERE description != 'boring' AND id % 2 = 1
ORDER BY rating DESC;
```
关于奇数的判断，也可以用MOD()函数来完成，`MOD(id, 2) = 1`确定奇数id。

### 627. Swap Salary 交换工资
题目描述：https://leetcode.com/problems/swap-salary/

思路：感觉这个题目应该叫交换性别。。使用CASE WHEN或者IF语句实现判断

通过代码：

```sql
UPDATE salary SET sex = (
    CASE sex
        WHEN 'f' THEN 'm' 
        ELSE 'f' 
    END
);
```
或者
```sql
UPDATE salary SET sex = IF( sex='f', 'm', 'f');
```

### 1050 Actors and Directors Who Cooperated At Least Three Times 合作过至少三次的演员和导演
题目描述：
```
Table: ActorDirector

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| actor_id    | int     |
| director_id | int     |
| timestamp   | int     |
+-------------+---------+
timestamp is the primary key column for this table.

Write a SQL query for a report that provides the pairs (actor_id, director_id) where
the actor have cooperated with the director at least 3 times.

Example:

ActorDirector table:
+-------------+-------------+-------------+
| actor_id    | director_id | timestamp   |
+-------------+-------------+-------------+
| 1           | 1           | 0           |
| 1           | 1           | 1           |
| 1           | 1           | 2           |
| 1           | 2           | 3           |
| 1           | 2           | 4           |
| 2           | 1           | 5           |
| 2           | 1           | 6           |
+-------------+-------------+-------------+

Result table:
+-------------+-------------+
| actor_id    | director_id |
+-------------+-------------+
| 1           | 1           |
+-------------+-------------+
The only pair is (1, 1) where they cooperated exactly 3 times.

```
思路：找出合作至少三次的(演员，导演)，那么将ActorDirector分组，只有actor_id和director_id一样的才算一组，然后统计这样的组的数量。

通过代码：

```sql
SELECT actor_id, director_id
FROM ActorDirector
GROUP BY actor_id, director_id
HAVING COUNT(*) >= 3;
```

### 1068 Product Sales Analysis I  产品销售分析 I
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
(sale_id, year) is the primary key of this table.
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

Write an SQL query that reports all product names of the products in the 
Sales table along with their selling year and price.

For example:

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
+--------------+-------+-------+
| product_name | year  | price |
+--------------+-------+-------+
| Nokia        | 2008  | 5000  |
| Nokia        | 2009  | 5000  |
| Apple        | 2011  | 9000  |
+--------------+-------+-------+

```

思路：将Sales表和Product外连接，条件设为产品id相同，取出题目要求的内容。

通过代码：

```sql
SELECT P.product_name, S.year, S.price
FROM Sales AS S LEFT JOIN Product AS P
ON S.product_id = P.product_id;
```

### 1069 Product Sales Analysis II	产品销售分析 II 
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

Write an SQL query that reports the total quantity sold for every product id.

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
+--------------+----------------+
| product_id   | total_quantity |
+--------------+----------------+
| 100          | 22             |
| 200          | 15             |
+--------------+----------------+
```
思路：按照 `product_id` 进行分组，对每组内的`quantity`求和。

通过代码：
```sql
SELECT P.product_id, SUM(S.quantity) AS total_quantity
FROM Sales AS S LEFT JOIN Product AS P
ON S.product_id = P.product_id
GROUP BY product_id;
```
### 1075 Project Employees I 项目员工 I
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


Write an SQL query that reports the average experience years of all the employees 
for each project, rounded to 2 digits.

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
| 3           | John   | 1                |
| 4           | Doe    | 2                |
+-------------+--------+------------------+

Result table:
+-------------+---------------+
| project_id  | average_years |
+-------------+---------------+
| 1           | 2.00          |
| 2           | 2.50          |
+-------------+---------------+
The average experience years for the first project is (3 + 2 + 1) / 3 = 2.00 and 
for the second project is (3 + 2) / 2 = 2.50
```
思路：连接项目表和员工表，对项目表中的项目id进行分组，求出每个组中的员工的平均工作年龄，取2位小数。

通过代码：

```sql
SELECT P.project_id, ROUND(AVG(E.experience_years), 2) AS average_years
FROM Project AS P INNER JOIN Employee AS E
ON P.employee_id = E.employee_id
GROUP BY P.project_id;
```

### 1076 Project Employees II  项目员工 II
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

Write an SQL query that reports all the projects that have the most employees.

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
| 3           | John   | 1                |
| 4           | Doe    | 2                |
+-------------+--------+------------------+

Result table:
+-------------+
| project_id  |
+-------------+
| 1           |
+-------------+
The first project has 3 employees while the second one has 2.
```
思路：题目要求出员工最多的项目，那么先找出每个项目都有多少人，这里需要将项目分组，利用COUNT()函数计算人数，然后将人数逆序，取第一个，就到得了员工最多的。最后利用HAVING条件过滤得到项目id。

通过代码：

```sql
SELECT project_id 
FROM Project
GROUP BY project_id
HAVING COUNT(employee_id) = (
    SELECT COUNT(employee_id) AS cnt
    FROM Project
    GROUP BY project_id
    ORDER BY COUNT(employee_id) DESC  --得到各组项目员工人数的逆序
    LIMIT 1 OFFSET 0
);
```

### 1082. Sales Analysis I 	销售分析 I 
题目描述：
```
Table: Product

+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| product_id   | int     |
| product_name | varchar |
| unit_price   | int     |
+--------------+---------+
product_id is the primary key of this table.

Table: Sales
+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| seller_id   | int     |
| product_id  | int     |
| buyer_id    | int     |
| sale_date   | date    |
| quantity    | int     |
| price       | int     |
+------ ------+---------+
This table has no primary key, it can have repeated rows.
product_id is a foreign key to Product table.
 
Write an SQL query that reports the best seller by total sales price, If there is a tie,
report them all.

The query result format is in the following example:

Product table:
+------------+--------------+------------+
| product_id | product_name | unit_price |
+------------+--------------+------------+
| 1          | S8           | 1000       |
| 2          | G4           | 800        |
| 3          | iPhone       | 1400       |
+------------+--------------+------------+

Sales table:
+-----------+------------+----------+------------+----------+-------+
| seller_id | product_id | buyer_id | sale_date  | quantity | price |
+-----------+------------+----------+------------+----------+-------+
| 1         | 1          | 1        | 2019-01-21 | 2        | 2000  |
| 1         | 2          | 2        | 2019-02-17 | 1        | 800   |
| 2         | 2          | 3        | 2019-06-02 | 1        | 800   |
| 3         | 3          | 4        | 2019-05-13 | 2        | 2800  |
+-----------+------------+----------+------------+----------+-------+

Result table:
+-------------+
| seller_id   |
+-------------+
| 1           |
| 3           |
+-------------+
Both sellers with id 1 and 3 sold products with the most total price of 2800.

```

思路：找出总售价最高的卖家，和上面一道员工最多的项目思路是一样的，只不过那个是统计数量，这个是计算总和。先找出每个卖家的总售价和，逆序排序取第一个得到最高的总售价，最后使用HAVING过滤出与最高总售价相等的卖家id。

通过代码：

```sql
SELECT seller_id
FROM Sales
GROUP BY seller_id
HAVING SUM(price) = (
    SELECT SUM(price)
    FROM Sales
    GROUP BY seller_id
    ORDER BY SUM(price) DESC
    LIMIT 0,1
);

```
### 1083 Sales Analysis II 销售分析 II
题目描述：
```
Table: Product
+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| product_id   | int     |
| product_name | varchar |
| unit_price   | int     |
+--------------+---------+
product_id is the primary key of this table.

Table: Sales
+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| seller_id   | int     |
| product_id  | int     |
| buyer_id    | int     |
| sale_date   | date    |
| quantity    | int     |
| price       | int     |
+------ ------+---------+
This table has no primary key, it can have repeated rows.
product_id is a foreign key to Product table.

Write an SQL query that reports the buyers who have bought S8 but not iPhone. 
Note that S8 and iPhone are products present in the Product table.

The query result format is in the following example:

Product table:
+------------+--------------+------------+
| product_id | product_name | unit_price |
+------------+--------------+------------+
| 1          | S8           | 1000       |
| 2          | G4           | 800        |
| 3          | iPhone       | 1400       |
+------------+--------------+------------+

Sales table:
+-----------+------------+----------+------------+----------+-------+
| seller_id | product_id | buyer_id | sale_date  | quantity | price |
+-----------+------------+----------+------------+----------+-------+
| 1         | 1          | 1        | 2019-01-21 | 2        | 2000  |
| 1         | 2          | 2        | 2019-02-17 | 1        | 800   |
| 2         | 1          | 3        | 2019-06-02 | 1        | 800   |
| 3         | 3          | 3        | 2019-05-13 | 2        | 2800  |
+-----------+------------+----------+------------+----------+-------+

Result table:
+-------------+
| buyer_id    |
+-------------+
| 1           |
+-------------+
The buyer with id 1 bought an S8 but didn't buy an iPhone. 
The buyer with id 3 bought both.

```

思路：要找出购买了S8但是没有买iPhone的，那么首先找出所有买了S8的buyer_id，再找出这些buyer_id中没有买过iPhone的。

通过代码：

```sql
SELECT DISTINCT S.buyer_id
FROM Sales AS S LEFT JOIN Product AS P
ON S.product_id = P.product_id
WHERE P.product_name = 'S8'
AND S.buyer_id NOT IN (
    SELECT S.buyer_id
    FROM Sales AS S LEFT JOIN Product AS P
    ON S.product_id = P.product_id
    WHERE P.product_name = 'iPhone'
)
```
### 1084 Sales Analysis III 销售分析 III
题目描述：
```
Table: Product
+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| product_id   | int     |
| product_name | varchar |
| unit_price   | int     |
+--------------+---------+
product_id is the primary key of this table.

Table: Sales
+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| seller_id   | int     |
| product_id  | int     |
| buyer_id    | int     |
| sale_date   | date    |
| quantity    | int     |
| price       | int     |
+------ ------+---------+
This table has no primary key, it can have repeated rows.
product_id is a foreign key to Product table.
 
Write an SQL query that reports the products that were only sold in spring 2019. 
That is, between 2019-01-01 and 2019-03-31 inclusive.

The query result format is in the following example:

Product table:
+------------+--------------+------------+
| product_id | product_name | unit_price |
+------------+--------------+------------+
| 1          | S8           | 1000       |
| 2          | G4           | 800        |
| 3          | iPhone       | 1400       |
+------------+--------------+------------+

Sales table:
+-----------+------------+----------+------------+----------+-------+
| seller_id | product_id | buyer_id | sale_date  | quantity | price |
+-----------+------------+----------+------------+----------+-------+
| 1         | 1          | 1        | 2019-01-21 | 2        | 2000  |
| 1         | 2          | 2        | 2019-02-17 | 1        | 800   |
| 2         | 2          | 3        | 2019-06-02 | 1        | 800   |
| 3         | 3          | 4        | 2019-05-13 | 2        | 2800  |
+-----------+------------+----------+------------+----------+-------+

Result table:
+-------------+--------------+
| product_id  | product_name |
+-------------+--------------+
| 1           | S8           |
+-------------+--------------+
The product with id 1 was only sold in spring 2019 while the other two were sold after.
```

思路：跟上一题类似，找出**只在**第一季度卖过的商品，那么先找出第一季卖的商品，再找出这些商品中没有在其他季度卖过的。

通过代码：
```sql
SELECT DISTINCT P.product_id, P.product_name
FROM Sales AS S LEFT JOIN Product AS P
ON S.product_id = P.product_id
WHERE S.sale_date BETWEEN '2019-01-01' AND '2019-03-31'
AND P.product_id NOT IN (
    SELECT P.product_id
    FROM Sales AS S LEFT JOIN Product AS P
    ON S.product_id = P.product_id
    WHERE S.sale_date NOT BETWEEN '2019-01-01' AND '2019-03-31'
)
```
另一种思路：先找出所有卖过的商品记为A，选出在其他季度卖过的商品记为B，那么A-B做差就是只在第一季度卖的商品。

```sql

SELECT DISTINCT P.product_id, P.product_name
FROM Product AS P INNER JOIN Sales AS A
ON P.product_id = A.product_id
LEFT JOIN
(
    SELECT DISTINCT S.product_id
    FROM Sales AS S
    WHERE S.sale_date NOT BETWEEN '2019-01-01' AND '2019-03-31'

) AS B
ON A.product_id = B.product_id
WHERE B.product_id IS NULL;

```
本题思路来自：http://www.jasonpeng.cn/2019/08/18/leetcode1084-sales-analysis-iii/

### 1113 Reported Posts
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

The action column is an ENUM type of ('view', 'like', 'reaction', 
'comment', 'report', 'share').

The extra column has optional information about the action such as a reason for 
report or a type of reaction. 

Write an SQL query that reports the number of posts reported yesterday for 
each report reason. Assume today is 2019-07-05.

The query result format is in the following example:

Actions table:
+---------+---------+-------------+--------+--------+
| user_id | post_id | action_date | action | extra  |
+---------+---------+-------------+--------+--------+
| 1       | 1       | 2019-07-01  | view   | null   |
| 1       | 1       | 2019-07-01  | like   | null   |
| 1       | 1       | 2019-07-01  | share  | null   |
| 2       | 4       | 2019-07-04  | view   | null   |
| 2       | 4       | 2019-07-04  | report | spam   |
| 3       | 4       | 2019-07-04  | view   | null   |
| 3       | 4       | 2019-07-04  | report | spam   |
| 4       | 3       | 2019-07-02  | view   | null   |
| 4       | 3       | 2019-07-02  | report | spam   |
| 5       | 2       | 2019-07-04  | view   | null   |
| 5       | 2       | 2019-07-04  | report | racism |
| 5       | 5       | 2019-07-04  | view   | null   |
| 5       | 5       | 2019-07-04  | report | racism |
+---------+---------+-------------+--------+--------+

Result table:
+---------------+--------------+
| report_reason | report_count |
+---------------+--------------+
| spam          | 1            |
| racism        | 2            |
+---------------+--------------+ 
Note that we only care about report reasons with non zero number of reports.

```

思路：

通过代码：

```sql


```

### 1141 User Activity for the Past 30 Days I 
题目描述：
```
Table: Activity
+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| user_id       | int     |
| session_id    | int     |
| activity_date | date    |
| activity_type | enum    |
+---------------+---------+
There is no primary key for this table, it may have duplicate rows.
The activity_type column is an ENUM of type ('open_session', 'end_session', 'scroll_down', 'send_message').
The table shows the user activities for a social media website. 
Note that each session belongs to exactly one user.
 

Write an SQL query to find the daily active user count for a period of 30 days ending 2019-07-27 inclusively. A user was active on some day if he/she made at least one activity on that day.

The query result format is in the following example:

Activity table:
+---------+------------+---------------+---------------+
| user_id | session_id | activity_date | activity_type |
+---------+------------+---------------+---------------+
| 1       | 1          | 2019-07-20    | open_session  |
| 1       | 1          | 2019-07-20    | scroll_down   |
| 1       | 1          | 2019-07-20    | end_session   |
| 2       | 4          | 2019-07-20    | open_session  |
| 2       | 4          | 2019-07-21    | send_message  |
| 2       | 4          | 2019-07-21    | end_session   |
| 3       | 2          | 2019-07-21    | open_session  |
| 3       | 2          | 2019-07-21    | send_message  |
| 3       | 2          | 2019-07-21    | end_session   |
| 4       | 3          | 2019-06-25    | open_session  |
| 4       | 3          | 2019-06-25    | end_session   |
+---------+------------+---------------+---------------+

Result table:
+------------+--------------+ 
| day        | active_users |
+------------+--------------+ 
| 2019-07-20 | 2            |
| 2019-07-21 | 2            |
+------------+--------------+ 
Note that we do not care about days with zero active users.
```

思路：

通过代码：

```sql


```


### 1142 User Activity for the Past 30 Days II
题目描述：
```
Table: Activity
+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| user_id       | int     |
| session_id    | int     |
| activity_date | date    |
| activity_type | enum    |
+---------------+---------+
There is no primary key for this table, it may have duplicate rows.
The activity_type column is an ENUM of type ('open_session', 'end_session', 'scroll_down', 'send_message').
The table shows the user activities for a social media website.
Note that each session belongs to exactly one user.

Write an SQL query to find the average number of sessions per user for a period of 30 days ending 2019-07-27 inclusively, rounded to 2 decimal places. The sessions we want to count for a user are those with at least one activity in that time period.

The query result format is in the following example:

Activity table:
+---------+------------+---------------+---------------+
| user_id | session_id | activity_date | activity_type |
+---------+------------+---------------+---------------+
| 1       | 1          | 2019-07-20    | open_session  |
| 1       | 1          | 2019-07-20    | scroll_down   |
| 1       | 1          | 2019-07-20    | end_session   |
| 2       | 4          | 2019-07-20    | open_session  |
| 2       | 4          | 2019-07-21    | send_message  |
| 2       | 4          | 2019-07-21    | end_session   |
| 3       | 2          | 2019-07-21    | open_session  |
| 3       | 2          | 2019-07-21    | send_message  |
| 3       | 2          | 2019-07-21    | end_session   |
| 3       | 5          | 2019-07-21    | open_session  |
| 3       | 5          | 2019-07-21    | scroll_down   |
| 3       | 5          | 2019-07-21    | end_session   |
| 4       | 3          | 2019-06-25    | open_session  |
| 4       | 3          | 2019-06-25    | end_session   |
+---------+------------+---------------+---------------+

Result table:
+---------------------------+ 
| average_sessions_per_user |
+---------------------------+ 
| 1.33                      |
+---------------------------+ 
User 1 and 2 each had 1 session in the past 30 days while user 3 had 2 sessions so the average is (1 + 1 + 2) / 3 = 1.33.
```

思路：

通过代码：

```sql


```


### 1148 Article Views I 
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

Write an SQL query to find all the authors that viewed at least one of their own articles, sorted in ascending order by their id.

The query result format is in the following example:

Views table:
+------------+-----------+-----------+------------+
| article_id | author_id | viewer_id | view_date  |
+------------+-----------+-----------+------------+
| 1          | 3         | 5         | 2019-08-01 |
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
| 4    |
| 7    |
+------+
```

思路：

通过代码：

```sql


```


### 1173 Immediate Food Delivery I 
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

Write an SQL query to find the percentage of immediate orders in the table, rounded to 2 decimal places.

The query result format is in the following example:

Delivery table:
+-------------+-------------+------------+-----------------------------+
| delivery_id | customer_id | order_date | customer_pref_delivery_date |
+-------------+-------------+------------+-----------------------------+
| 1           | 1           | 2019-08-01 | 2019-08-02                  |
| 2           | 5           | 2019-08-02 | 2019-08-02                  |
| 3           | 1           | 2019-08-11 | 2019-08-11                  |
| 4           | 3           | 2019-08-24 | 2019-08-26                  |
| 5           | 4           | 2019-08-21 | 2019-08-22                  |
| 6           | 2           | 2019-08-11 | 2019-08-13                  |
+-------------+-------------+------------+-----------------------------+

Result table:
+----------------------+
| immediate_percentage |
+----------------------+
| 33.33                |
+----------------------+
The orders with delivery id 2 and 3 are immediate while the others are scheduled.

```

思路：

通过代码：

```sql


```


### 1179. Reformat Department Table
题目描述：https://leetcode.com/problems/reformat-department-table/

思路：题目要求出每个id在1-12个月的收入，那么先把id进行分组，然后使用CASE WHEN来判断某月是否有收入，如果有就显示收入，没有就显示null。也可以把CASE WHEN换成IF()语句。

通过代码：

```sql
select id, 
	sum(case when month = 'jan' then revenue else null end) as Jan_Revenue,
	sum(case when month = 'feb' then revenue else null end) as Feb_Revenue,
	sum(case when month = 'mar' then revenue else null end) as Mar_Revenue,
	sum(case when month = 'apr' then revenue else null end) as Apr_Revenue,
	sum(case when month = 'may' then revenue else null end) as May_Revenue,
	sum(case when month = 'jun' then revenue else null end) as Jun_Revenue,
	sum(case when month = 'jul' then revenue else null end) as Jul_Revenue,
	sum(case when month = 'aug' then revenue else null end) as Aug_Revenue,
	sum(case when month = 'sep' then revenue else null end) as Sep_Revenue,
	sum(case when month = 'oct' then revenue else null end) as Oct_Revenue,
	sum(case when month = 'nov' then revenue else null end) as Nov_Revenue,
	sum(case when month = 'dec' then revenue else null end) as Dec_Revenue
from department
group by id
order by id;
```


