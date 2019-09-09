/*


本文内容来自牛客网上数据库SQL实战，题目描述地址： https://www.nowcoder.com/ta/sql

题目顺序按照热度指数排序的，部分题目的思路来自该题目下热门讨论内容。

**1.查找最晚入职员工的所有信息**

思路：找出最晚入职的员工，即入职的时间是最大的，使用子查询将该条件作为过滤条件。
```sql
SELECT * FROM employees 
WHERE hire_date = (SELECT MAX(hire_date) FROM employees);
```
其他思路：把入职时间降序排序，那么排在最前面的就是入职时间最大的，也是最晚入职的员工,然后取该排序序列的第一个。
```sql
SELECT * FROM employees 
ORDER BY hire_date DESC 
LIMIT 1
```
但是这个思路不太严谨，摘自该题目后fsy351的解释：最晚入职的当天未必就一个人，也许有多人，使用排序并限制得只能取得指定数量的结果

**2.查找入职员工时间排名倒数第三的员工所有信息**

思路：把入职时间倒序排序，然后使用LIMIT关键字。
```sql
SELECT * FROM employees 
ORDER BY hire_date DESC
LIMIT 2,1; 
```
LIMIT m,n : 表示从第m+1条开始，取n条数据；
LIMIT n ： 表示从第0条开始，取n条数据，是limit(0,n)的缩写。

但是这样写不太严谨，比如有多个员工在同一天入职，那么应该按入职日期进行分组，将多个入职日期相同的分为一组，再排序，这样入职时间倒数第三的员工就都可以查出来了。
```sql
SELECT * FROM employees 
WHERE hire_date = (
SELECT DISTINCT hire_date FROM employees 
ORDER BY hire_date DESC LIMIT 2,1
);
```

**3.查找各个部门当前(to_date='9999-01-01')领导当前薪水详情以及其对应部门编号dept_no**

思路：把两张表关联起来，设定条件为to_date=9999-01-01  
```sql
SELECT sa.*,dm.dept_no
FROM salaries AS sa INNER JOIN dept_manager AS dm ON dm.emp_no = sa.emp_no
WHERE sa.to_date = '9999-01-01' AND dm.to_date='9999-01-01';
```

**4.查找所有已经分配部门的员工的last_name和first_name**


```sql
SELECT em.last_name, em.first_name, de.dept_no
FROM dept_emp AS de INNER JOIN employees AS em ON de.emp_no = em.emp_no;
```

**5.查找所有员工的last_name和first_name以及对应部门编号dept_no，也包括展示没有分配具体部门的员工**

思路：以员工为主表，这样即使没有分配部门的员工也可展示出来。
```sql
SELECT em.last_name, em.first_name, de.dept_no
FROM employees AS em LEFT JOIN dept_emp AS de ON de.emp_no = em.emp_no;
```

**6.查找所有员工入职时候的薪水情况，给出emp_no以及salary， 并按照emp_no进行逆序**

第一次我的错误的写法：
```sql
SELECT ep.emp_no, sa.salary
FROM employees AS ep INNER JOIN salaries AS sa ON ep.emp_no = sa.emp_no
ORDER BY ep.emp_no DESC;
```
刚开始没有明白错在哪里，看讨论区后才知道读题不认真，要求的是查入职时候的薪水，而在salaries表中，每个号码为emp_no的员工会在不同时间段涨薪，这样一个emp_no就对应了多个salary。

因此按照题目要求的查入职时候的薪水，添加条件sa.from_date = ep.hire_date，正确写法：
```sql
SELECT ep.emp_no, sa.salary
FROM employees AS ep INNER JOIN salaries AS sa ON ep.emp_no = sa.emp_no
WHERE sa.from_date = ep.hire_date
ORDER BY ep.emp_no DESC;
```

**7.查找薪水涨幅超过15次的员工号emp_no以及其对应的涨幅次数t**

思路：把员工分组，使用COUNT()函数计算涨幅次数，使用HAVING条件过滤涨幅次数大于15的，

```sql
SELECT emp_no, COUNT(salary) AS t
FROM salaries
GROUP BY emp_no
HAVING t>15;
```
这样虽然可以通过，但是并不完全正确。COUNT()只是统计次数，并不能判定“涨薪”。
比如emp_no为10002的员工：
+--------+--------+------------+------------+
| emp_no | salary | from_date  | to_date    |
+--------+--------+------------+------------+
| 10002  |  72527 | 1996-08-03 | 1997-08-03 |
|  10002 |  72527 | 1997-08-03 | 1998-08-03 |
|  10002 |  72527 | 1998-08-03 | 1999-08-03 |
|  10002 |  72527 | 1999-08-03 | 2000-08-02 |
|  10002 |  72527 | 2000-08-02 | 2001-08-02 |
|  10002 |  72527 | 2001-08-02 | 9999-01-01 |

COUNT()统计次数有6次，但是涨薪次数为0次。
因此还应该加入下次的salary比本次的salary高，才统计为一次涨薪

```sql
SELECT s1.emp_no, COUNT(s1.emp_no) AS t
FROM salaries AS s1 INNER JOIN salaries AS s2
ON s1.emp_no = s2.emp_no
WHERE s1.salary < s2.salary AND s1.to_date = s2.from_date
GROUP BY emp_no
HAVING COUNT(s1.emp_no)>15;
```
不过这个题目这样解没有给通过

**8.找出所有员工当前(to_date='9999-01-01')具体的薪水salary情况，对于相同的薪水只显示一次,并按照逆序显示**

思路：使用DISTINCT去重，DESC逆序排列

```sql
SELECT DISTINCT salary
FROM salaries
WHERE to_date = '9999-01-01'
ORDER BY salary DESC;
```
其他思路： 如果是针对大量数据的去重，可以使用GROUP BY解决去重，
```sql
SELECT salary
FROM salaries
WHERE to_date = '9999-01-01'
GROUP BY salary
ORDER BY salary DESC;
```

**9. 获取所有部门当前manager的当前薪水情况，给出dept_no, emp_no以及salary，当前表示to_date='9999-01-01'**

思路：将两表联结，取出题目需要的。注意要求的是当前manager的当前薪水情况，两个当前条件都要满足，这里又错了一遍。。
```sql
SELECT dm.dept_no, dm.emp_no, sa.salary
FROM dept_manager AS dm INNER JOIN salaries AS sa ON dm.emp_no = sa.emp_no
WHERE dm.to_date = '9999-01-01' AND sa.to_date = '9999-01-01';
```
**10. 获取所有非manager的员工emp_no**

思路：先选出所有manager员工的emp_no，再用NOT IN过滤掉这些emp_no

```sql
SELECT emp_no FROM employees
WHERE emp_no NOT IN (
    SELECT emp_no
    FROM dept_manager
);
```

其他思路：
```sql
SELECT em.emp_no
FROM employees AS em
WHERE NOT EXISTS(
    SELECT emp_no
    FROM dept_manager AS dm
    WHERE em.emp_no = dm.emp_no
);

```
其他思路：
```sql
SELECT em.emp_no
FROM employees AS em LEFT JOIN dept_manager AS dm
ON em.emp_no = dm.emp_no
WHERE dm.dept_no IS NULL;
```

**11.获取所有员工当前的manager，如果当前的manager是自己的话结果不显示，当前表示to_date='9999-01-01'。结果第一列给出当前员工的emp_no,第二列给出其manager对应的manager_no。**
思路：员工的当前管理者：那么员工所在部门`dept_no`与管理者所在部门`dept_no`应该是相同的，通过这点将dept_emp表和dept_manager表联结起来，然后判断当前的manager是自己，可以通过员工表中的emp_no和管理者表中emp_no，这两个编号相同即当前的manager是自己，最后设定当前时间。还需要注意员工的manager对应的manager_no在表中是没有的，这个编号就是管理表中的emp_no,把他起个别名manager_no就可以。

```sql
SELECT de.emp_no,dm.emp_no AS manager_no
FROM dept_emp AS de INNER JOIN dept_manager AS dm ON de.dept_no = dm.dept_no
WHERE de.to_date='9999-01-01' AND dm.to_date = '9999-01-01' AND de.emp_no != dm.emp_no;
```

**12.获取所有部门中当前员工薪水最高的相关信息，给出dept_no, emp_no以及其对应的salary**

```sql
SELECT de.dept_no,  MAX(sa.salary) AS salary
FROM salaries AS sa INNER JOIN dept_emp AS de
ON sa.emp_no = de.emp_no
WHERE de.to_date='9999-01-01' AND sa.to_date='9999-01-01'
GROUP BY de.dept_no
ORDER BY de.dept_no; 
```


**13.从titles表获取按照title进行分组，每组个数大于等于2，给出title以及对应的数目t。**

```sql
SELECT title, COUNT(title) AS t
FROM titles
GROUP BY title
HAVING COUNT(title) >= 2;
```

**14.从titles表获取按照title进行分组，每组个数大于等于2，给出title以及对应的数目t。注意对于重复的title进行忽略。**
思路： 这个题和13题的区别在于，对重复的title进行去重，比如题目给的数据中，
+--------+--------------------+------------+------------+
| emp_no | title              | from_date  | to_date    |
+--------+--------------------+------------+------------+
|  10010 | Engineer           | 1996-11-24 | 9999-01-01 |
|  10010 | Engineer           | 1996-11-24 | 9999-01-01 |
+--------+--------------------+------------+------------+
重复的title指的是emp_no中重复的，因此对emp_no去重
```sql
SELECT title, COUNT(DISTINCT emp_no) AS t
FROM titles
GROUP BY title
HAVING t >= 2;
```
**15.查找employees表所有emp_no为奇数，且last_name不为Mary的员工信息，并按照hire_date逆序排列**

```sql
SELECT *
FROM employees
WHERE emp_no % 2 = 1 AND last_name != 'Mary' 
ORDER BY hire_date DESC;
```

**16. 统计出当前各个title类型对应的员工当前（to_date='9999-01-01'）薪水对应的平均工资。结果给出title以及平均工资avg。**

```sql
SELECT title, AVG(sa.salary) AS avg
FROM titles AS ti INNER JOIN salaries AS sa ON ti.emp_no = sa.emp_no
WHERE sa.to_date = '9999-01-01' AND ti.to_date = '9999-01-01'
GROUP BY ti.title;
```

**17.获取当前（to_date='9999-01-01'）薪水第二多的员工的emp_no以及其对应的薪水salary**

我开始是这样写的，也通过了
```sql
SELECT emp_no,salary
FROM salaries
WHERE to_date = '9999-01-01'
ORDER BY salary DESC
LIMIT 1,1;
```
但是看评论时候才发现不严谨，自己想的不够周全，题目要的是薪水第二多的，假如在公司中，当前薪水第一多(设为100万)的有3个人，薪水第二多的有1个人(设为80万)，那么按照上面的排序，结果是：
```
100万
100万
100万
80万
```
而`LIMIT 1,1`选到的是第二个，是100万，但是题目要的是选出80万的，因此，应该对薪水同样多的进行去重，正确的写法:
```sql
SELECT emp_no,salary
FROM salaries
WHERE salary = (
    SELECT salary FROM salaries
    WHERE to_date = '9999-01-01'
    GROUP BY salary
    ORDER BY salary DESC
    LIMIT 1,1
)
AND to_date = '9999-01-01';
```

**18.查找当前薪水(to_date='9999-01-01')排名第二多的员工编号emp_no、薪水salary、last_name以及first_name，不准使用order by**

先用MAX()函数选出当前最高者：`SELECT MAX(salary) FROM salaries WHERE to_date='9999-01-01'`
然后在小于最高者的薪水中再选出最高者，即当前排名第二高的：
```sql
SELECT MAX(salary) FROM salaries
    WHERE salary < (SELECT MAX(salary) FROM salaries WHERE to_date='9999-01-01')
          AND to_date = '9999-01-01'
```
最后，联结employees表，选出编号，姓名：
```sql
SELECT emp.emp_no,sa.salary,emp.last_name,emp.first_name
FROM salaries AS sa INNER JOIN employees AS emp 
ON sa.emp_no = emp.emp_no
WHERE to_date='9999-01-01' AND salary = (
    SELECT MAX(salary) FROM salaries
    WHERE salary < (SELECT MAX(salary) FROM salaries WHERE to_date='9999-01-01')
    AND to_date = '9999-01-01'
);

```
**19.查找所有员工的last_name和first_name以及对应的dept_name，也包括暂时没有分配部门的员工**
思路：将三张表联结起来，因为要包括暂时没有分配部门的员工，使用LEFT JOIN

```sql
SELECT emp.last_name, emp.first_name, dpm.dept_name
FROM employees AS emp LEFT JOIN dept_emp AS dep ON emp.emp_no = dep.emp_no
                      LEFT JOIN departments AS dpm ON dep.dept_no = dpm.dept_no;

```

**20.查找员工编号emp_no为10001其自入职以来的薪水salary涨幅值growth**

可以通过但是不严谨的写法：

```sql
SELECT (MAX(salary)-MIN(salary)) AS growth
FROM salaries
WHERE emp_no = 10001;

```
如果考虑到工资不是一直涨的，比如入职时工资1万，两年后3万，再过半年降成2.5万，现在工资是2.7万，那么入职以来薪水涨幅值是1.7万，而不是3-1=2万
因此，应该将最近一次工资减去入职时候第一次的工资，得到的才是涨幅值
```sql
SELECT (
    (SELECT salary FROM salaries WHERE emp_no = 10001 ORDER BY to_date DESC LIMIT 1) -
    (SELECT salary FROM salaries WHERE emp_no = 10001 ORDER BY to_date ASC LIMIT 1)
) AS growth;

```
**21.查找所有员工自入职以来的薪水涨幅情况，给出员工编号emp_no以及其对应的薪水涨幅growth，并按照growth进行升序**
思路：本题是求所有员工的，因此可以考虑把薪水salaries表做两份，一份表示当前的，用来得到当前的薪水sa1.salary，另一份是入职时的，用来得到入职时候的薪水sa2.salary。当前这个条件可以设为`to_date='9999-01-01'`，入职时候的条件可以设为`emp.hire_date = sa2.from_date`，那么涨幅情况就可以用当前薪水-入职时的薪水：`sa1.salary-sa2.salary`

```sql
SELECT emp.emp_no, (sa1.salary-sa2.salary) AS growth
FROM employees AS emp INNER JOIN salaries AS sa1 
                            ON emp.emp_no = sa1.emp_no AND sa1.to_date='9999-01-01'
                      INNER JOIN salaries AS sa2
                            ON emp.emp_no = sa2.emp_no AND emp.hire_date = sa2.from_date
ORDER BY growth ASC;
```
**22.统计各个部门对应员工涨幅的次数总和，给出部门编码dept_no、部门名称dept_name以及次数sum**


思路：可以通过牛客网提交但是不周全的方案：三表联结，对部分分组，使用COUNT()统计次数


```sql
SELECT dm.dept_no, dm.dept_name, COUNT(salary) AS sum
FROM salaries AS sa INNER JOIN dept_emp AS de ON sa.emp_no = de.emp_no
                    INNER JOIN departments AS dm ON dm.dept_no = de.dept_no
GROUP BY dm.dept_no, dm.dept_name;

```
和前面一道涨幅次数超过15次的题目很像，需要判定是涨的记录，而不是不变或降的记录。因此我这样写的，但是没有通过提交。

```sql
SELECT dm.dept_no, dm.dept_name, COUNT(sa1.emp_no) AS sum
FROM salaries AS sa1 INNER JOIN salaries AS sa2 ON sa1.emp_no = sa2.emp_no
                     INNER JOIN dept_emp AS de ON sa1.emp_no = de.emp_no
                     INNER JOIN departments AS dm ON dm.dept_no = de.dept_no
WHERE sa1.salary<sa2.salary AND sa1.to_date = sa2.from_date
GROUP BY dm.dept_no, dm.dept_name;
```

**23.对所有员工的当前(to_date='9999-01-01')薪水按照salary进行按照1-N的排名，相同salary并列且按照emp_no升序排列**

思路：如果支持窗口函数，根据相同的salary并列，排名为：1,2,2,3,3,3,4这样的顺序，那么可以使用dense_rank()窗口函数。

```sql
SELECT emp_no, salary, dense_rank() OVER (ORDER BY salary DESC) AS rank
FROM salaries 
WHERE to_date='9999-01-01'
ORDER BY salary DESC, emp_no ASC;
```
但是如果不支持窗口函数，要对工资进行1-N的排名，不用窗口函数对单个表显示排名，我一开始没有思路，，后来看了讨论区，理解了热评里的实现过程。把salary表做成两份，进行对比，一份是原表sa1，另一份是排名用的表sa2。如果某工资排名第五，那么就是说有比他工资高(`sa1.salary <= sa2.salary`)的有4份，如果某工资排名第二，那么就是说有比他工资高有1份，可以使用COUNT()来统计比某份工资高的个数来当做排名。
还需要注意去重，比如s1.salary=94409时，有3个s2.salary（分别为94692,94409,94409）大于等于它，但由于94409重复，利用COUNT(DISTINCT s2.salary)去重可得工资为94409的rank等于2
最后排名时，工资salary逆序排，最大的为第一名，emp_no升序排列

```sql
SELECT sa1.emp_no, sa1.salary, COUNT(DISTINCT sa2.salary) AS rank
FROM salaries AS sa1 INNER JOIN salaries AS sa2 ON sa2.emp_no = sa2.emp_no
WHERE sa1.to_date = '9999-01-01' AND sa2.to_date = '9999-01-01' 
      AND sa1.salary <= sa2.salary
GROUP BY sa1.emp_no,sa1.salary
ORDER BY sa1.salary DESC, sa1.emp_no ASC;
```

**24.获取所有非manager员工当前的薪水情况，给出dept_no、emp_no以及salary ，当前表示to_date='9999-01-01'**


```sql
SELECT de.dept_no, sa.emp_no, sa.salary
FROM dept_emp AS de INNER JOIN salaries AS sa 
ON sa.emp_no = de.emp_no AND sa.to_date='9999-01-01'
WHERE de.emp_no NOT IN (
    SELECT emp_no FROM dept_manager WHERE to_date='9999-01-01'
);
```

**25.获取员工其当前的薪水比其manager当前薪水还高的相关信息，当前表示to_date='9999-01-01',结果第一列给出员工的emp_no，第二列给出其manager的manager_no，第三列给出该员工当前的薪水emp_salary,第四列给该员工对应的manager当前的薪水manager_salary**

来自本题热评中wasrehpic的思路：
本题主要思想是创建两张表（一张记录当前所有员工的工资，另一张只记录部门经理的工资）进行比较，具体思路如下：
1、先用INNER JOIN连接salaries和demp_emp，建立当前所有员工的工资记录sde
2、再用INNER JOIN连接salaries和demp_manager，建立当前所有经理的工资记录sdm
3、最后用限制条件sem.dept_no = sdm.dept_no AND sem.salary > sdm.salary找出同一部门中工资比经理高的员工，并根据题意依次输出emp_no、manager_no、emp_salary、manager_salary
```sql
SELECT sde.emp_no AS emp_no, sdm.emp_no AS manager_no, sde.salary AS emp_salary, sdm.salary AS manager_salary
FROM (
    SELECT sa.salary, sa.emp_no, de.dept_no
    FROM salaries AS sa INNER JOIN dept_emp AS de
    ON sa.emp_no = de.emp_no AND sa.to_date='9999-01-01'
    )AS sde,
    (
        SELECT sa.salary, sa.emp_no, dm.dept_no
        FROM salaries AS sa INNER JOIN dept_manager AS dm
        ON sa.emp_no = dm.emp_no AND sa.to_date='9999-01-01'
    ) AS sdm
WHERE sde.dept_no = sdm.dept_no AND sde.salary > sdm.salary;
```
**26.汇总各个部门当前员工的title类型的分配数目，结果给出部门编号dept_no、dept_name、其当前员工所有的title以及该类型title对应的数目count**
思路：首先需要对各个部门进行分组,分组后得到的每组是某个部门的员工。员工可能有多个类型的title，要统计某类型title对应的数目，还需要对title进行分组，这样两次分组后，只有同一部门且同一title的才是一个组。当前员工的当前title，员工和title都需要加to_date的限制。

```sql
SELECT de.dept_no, dm.dept_name, t.title, COUNT(t.title)
FROM departments AS dm INNER JOIN dept_emp AS de 
                       ON dm.dept_no = de.dept_no AND de.to_date='9999-01-01'
                       INNER JOIN titles AS t
                       ON de.emp_no = t.emp_no AND t.to_date='9999-01-01'
GROUP BY de.dept_no, t.title;
```

**27.给出每个员工每年薪水涨幅超过5000的员工编号emp_no、薪水变更开始日期from_date以及薪水涨幅值salary_growth，并按照salary_growth逆序排列。提示：在sqlite中获取datetime时间对应的年份函数为strftime('%Y', to_date)**

```sql
SELECT sa1.emp_no, sa2.from_date, (sa2.salary - sa1.salary) AS salary_growth
FROM salaries AS sa1 INNER JOIN salaries AS sa2 ON sa1.emp_no = sa2.emp_no
WHERE sa2.salary-sa1.salary>5000 
AND (
    strftime('%Y', sa2.to_date) - strftime('%Y', sa1.to_date) = 1
    OR
    strftime('%Y', sa2.from_date) - strftime('%Y', sa1.from_date) = 1
    )

ORDER BY salary_growth DESC;
```

**28.查找描述信息中包括robot的电影对应的分类名称以及电影数目，而且还需要该分类对应电影数量>=5部**

```sql
SELECT c.name,COUNT(fc.film_id)
FROM (
        SELECT category_id
        FROM film_category
        GROUP BY category_id
        HAVING COUNT(film_id) >= 5
    ) AS cc,
    film AS f,
    category AS c,
    film_category AS fc
WHERE f.description LIKE '%robot%'
AND c.category_id = fc.category_id
AND c.category_id = cc.category_id
AND fc.film_id = f.film_id;
```

**29.使用join查询方式找出没有分类的电影id以及名称**
方法一

```sql
SELECT f.film_id, f.title
FROM film AS f LEFT JOIN film_category AS fc
ON f.film_id = fc.film_id
WHERE fc.category_id IS NULL;
```

方法二
```sql
SELECT film.film_id, film.title
FROM film
WHERE film.film_id NOT IN (
    SELECT film_id
    FROM film_category
);
```

**30.使用子查询的方式找出属于Action分类的所有电影对应的title,description**

子查询方法：

```sql
SELECT title, description
FROM film
WHERE film_id IN (
    SELECT film_id
    FROM film_category
    WHERE category_id IN (
        SELECT category_id
        FROM category
        WHERE name = 'Action'
    )
);

```
非子查询方法

```sql
SELECT f.title, f.description
FROM film AS f INNER JOIN film_category AS fc ON f.film_id =fc.film_id
               INNER JOIN category AS c ON c.category_id = fc.category_id
WHERE c.name = 'Action';

```

**31.获取select * from employees对应的执行计划**

```sql
EXPLAIN SELECT * FROM employees;
```

**32.将employees表的所有员工的last_name和first_name拼接起来作为Name，中间以一个空格区分**

```sql
// mysql写法
SELECT concat(concat(last_name, " "), first_name)
FROM employees;

//sqlite写法
SELECT last_name||" "||first_name AS Name
FROM employees;
```

**33.创建一个actor表，包含如下列信息**

列表	类型	是否为NULL	含义
actor_id	smallint(5)	not null	主键id
first_name	varchar(45)	not null	名字
last_name	varchar(45)	not null	姓氏
last_update	timestamp	not null	最后更新时间，默认是系统的当前时间

```sql
//sqlite写法
CREATE TABLE IF NOT EXISTS actor(
    actor_id smallint(5) NOT NULL,
    first_name varchar(45) NOT NULL,
    last_name varchar(45) NOT NULL,
    last_update timestamp NOT NULL DEFAULT (datetime('now', 'localtime')),
    PRIMARY KEY(actor_id)
);

//mysql写法
CREATE TABLE IF NOT EXISTS actor(
    actor_id smallint(5) NOT NULL,
    first_name varchar(45) NOT NULL,
    last_name varchar(45) NOT NULL,
    last_update timestamp NOT NULL DEFAULT current_timestamp COMMENT '最后更新时间，默认是系统的当前时间',
    PRIMARY KEY(actor_id)
);

```

**34.对于表actor批量插入如下数据**
actor_id	first_name	last_name	last_update
1	PENELOPE	GUINESS	2006-02-15 12:34:33
2	NICK	WAHLBERG	2006-02-15 12:34:33

注意插入字符串时用引号
```sql
INSERT INTO actor VALUES(1, 'PENELOPE', 'GUINESS', '2006-02-15 12:34:33'),
                        (2, 'NICK', 'WAHLBERG', '2006-02-15 12:34:33');

//或者
INSERT INTO actor(actor_id, first_name, last_name, last_update) 
VALUES (1, 'PENELOPE', 'GUINESS', '2006-02-15 12:34:33'),
       (2, 'NICK', 'WAHLBERG', '2006-02-15 12:34:33');
```

**35. 对于表actor批量插入如下数据,如果数据已经存在，请忽略，不使用replace操作**

```sql
//sqlite
INSERT OR IGNORE INTO actor VALUES(3, 'ED', 'CHASE', '2006-02-15 12:34:33');

//mysql
INSERT IGNORE INTO actor VALUES(3, 'ED', 'CHASE', '2006-02-15 12:34:33');
```

**36.对于如下表actor，其对应的数据为:**
actor_id	first_name	last_name	last_update
1	PENELOPE	GUINESS	2006-02-15 12:34:33
2	NICK	WAHLBERG	2006-02-15 12:34:33

创建一个actor_name表，将actor表中的所有first_name以及last_name导入改表。 actor_name表结构如下：
列表	类型	是否为NULL	含义
first_name	varchar(45)	not null	名字
last_name	varchar(45)	not null	姓氏


```SQL
CREATE TABLE IF NOT EXISTS actor_name(
    first_name varchar(45) NOT NULL,
    last_name  varchar(45) NOT NULL
);

INSERT INTO actor_name (first_name, last_name) SELECT first_name, last_name FROM actor;

//或者
CREATE TABLE actor_name as SELECT first_name, last_name FROM actor;
```

**37. 对first_name创建唯一索引uniq_idx_firstname，对last_name创建普通索引idx_lastname**

```sql
CREATE UNIQUE INDEX uniq_idx_firstname ON actor(first_name);
CREATE INDEX idx_lastname ON actor(last_name);

```

**38.针对actor表创建视图actor_name_view，只包含first_name以及last_name两列，并对这两列重新命名，first_name为first_name_v，last_name修改为last_name_v**

```sql
CREATE VIEW actor_name_view (first_name_v, last_name_v) AS 
    SELECT first_name,last_name FROM actor
```

**39.针对salaries表emp_no字段创建索引idx_emp_no，查询emp_no为10005, 使用强制索引。**

```sql
//SQLite
SELECT * FROM salaries INDEXED BY idx_emp_no WHERE emp_no = 10005;

//MySQL
SELECT * FROM salaries FORCE INDEX idx_emp_no WHERE emp_no = 10005;
```

**40. 现在在last_update后面新增加一列名字为create_date, 类型为datetime, NOT NULL，默认值为'0000 00:00:00'**

```sql
ALTER TABLE actor ADD COLUMN create_date datetime NOT NULL DEFAULT '0000-00-00 00:00:00';

```

**41. 构造一个触发器audit_log，在向employees_test表中插入一条数据的时候，触发插入相关的数据到audit中。**

```sql
CREATE TRIGGER audit_log AFTER INSERT ON employees_test
BEGIN
    INSERT INTO audit VALUES (NEW.ID, NEW.NAME);
END;

```
**42. 删除emp_no重复的记录，只保留最小的id对应的记录。**
思路：先把emp_no分组，在每组中找出最小的id，然后把非最小的都给删掉

```sql
DELETE FROM titles_test WHERE id NOT IN (
    SELECT MIN(id) FROM titles_test GROUP BY emp_no
);
```
**43. 将所有to_date为9999-01-01的全部更新为NULL,且 from_date更新为2001-01-01。**

```sql
UPDATE titles_test SET to_date = NULL, from_date = '2001-01-01'
WHERE to_date='9999-01-01';
```

**44. 将id=5以及emp_no=10001的行数据替换成id=5以及emp_no=10005,其他数据保持不变，使用replace实现。**
```sql
REPLACE INTO titles_test VALUES('5', '10005', 'Senior Engineer', '1986-06-26', '9999-01-01');
```

**45. 将titles_test表名修改为titles_2017。**
```sql
ALTER TABLE titles_test RENAME TO titles_2017;
```

**46.在audit表上创建外键约束，其emp_no对应employees_test表的主键id。**
```sql
//mysql
ALTER TABLE audit ADD FROEIGN KEY (emp_no) REFERNCES employees_test (id);

//通过测试
DROP TABLE audit;
CREATE TABLE audit(
    EMP_no INT NOT NULL,
    create_date datetime NOT NULL,
    FOREIGN KEY(EMP_no) REFERENCES employees_test(ID));
```

**47.存在如下的视图：create view emp_v as select * from employees where emp_no >10005;如何获取emp_v和employees有相同的数据?**

INETRSECT和 UNION 指令类似，INTERSECT 也是对两个 SQL 语句所产生的结果做处理的。不同的地方是， UNION 基本上是一个 OR (如果这个值存在于第一句或是第二句，它就会被选出)，而 INTERSECT 则比较像 AND ( 这个值要存在于第一句和第二句才会被选出)。UNION 是联集，而 INTERSECT 是交集。

```sql
SELECT * FROM employees INTERSECT SELECT * FROM emp_v;
```

**48. 将所有获取奖金的员工当前的薪水增加10%。**
```sql
UPDATE salaries SET salary = salary * 1.1
WHERE to_date='9999-01-01' AND emp_no IN (
    SELECT emp_no FROM emp_bonus
);
```

**49. 针对库中的所有表生成select count(*)对应的SQL语句**

```sql
//sqlite
SELECT "select count(*) from " || name || ";" AS cnts
FROM sqlite_master WHERE type = 'table';

//mysql
SELECT concat('SELECT COUNT(*) FROM ', new.table_name, ';') AS cnts
FROM (
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = 'sql_nowcoder'
) AS new;

```

**50.将employees表中的所有员工的last_name和first_name通过(')连接起来。**
```sql
//sqlite
SELECT last_name || "'" || first_name
FROM employees;

//mysql
SELECT concat(last_name, "'", first_name)
FROM employees;
```

**51.查找字符串'10,A,B' 中逗号','出现的次数cnt。**

```sql
SELECT (
    (length("10,A,B") - length(replace("10,A,B", ",", ""))) / length(",")
) AS cnt;
```

**52.获取Employees中的first_name，查询按照first_name最后两个字母，按照升序进行排列**

substr(string,start,length)
- string 指定的要截取的字符串。
- start 必需，规定在字符串的何处开始。正数 - 在字符串的指定位置开始，负数 - 在从字符串结尾的指定位置开始，0 - 在字符串中的第一个字符处开始。
- length 可选，指定要截取的字符串长度，缺省时返回字符表达式的值结束前的全部字符。
```sql
//sqlite
SELECT first_name
FROM employees
ORDER BY substr(first_name, length(first_name)-1, 2) ASC;

//mysql
SELECT first_name
FROM employees
ORDER BY RIGHT(first_name,2) ASC;
```

**53.按照dept_no进行汇总，属于同一个部门的emp_no按照逗号进行连接，结果给出dept_no以及连接出的结果employees**

思路: 聚合函数group_concat(X,Y)，其中X是要连接的字段，Y是连接时用的符号，可省略，默认为逗号。此函数必须与 GROUP BY 配合使用。此题以 dept_no 作为分组，将每个分组中不同的emp_no用逗号连接起来（即可省略Y）。

```sql

SELECT dept_no, group_concat(emp_no) AS employees
FROM dept_emp
GROUP BY dept_no;
```

**54.查找排除当前最大、最小salary之后的员工的平均工资avg_salary。**

```sql
SELECT AVG(salary) AS avg_salary
FROM salaries 
WHERE to_date='9999-01-01' 
AND salary NOT IN (SELECT MAX(salary) FROM salaries WHERE to_date='9999-01-01' )
AND salary NOT IN (SELECT MIN(salary) FROM salaries WHERE to_date='9999-01-01' );
```

**55.分页查询employees表，每5行一页，返回第2页的数据**

思路：第2页的行数为第6-10行，可以用LIMIT 5, OFFSET 5

```SQL
SELECT * FROM employees LIMIT 5 OFFSET 5;
```

**56.获取所有员工的emp_no、部门编号dept_no以及对应的bonus类型btype和received ，没有分配具体的员工不显示**

```SQL
SELECT em.emp_no, de.dept_no, eb.btype, eb.recevied
FROM employees AS em INNER JOIN dept_emp AS de
ON em.emp_no = de.emp_no
LEFT JOIN emp_bonus AS eb 
ON de.emp_no = eb.emp_no;

```

**57.获取employees中的行数据，且这些行也存在于emp_v中。注意不能使用intersect关键字**

```sql
SELECT * FROM emp_v;
```

**58.获取有奖金的员工相关信息。给出emp_no、first_name、last_name、奖金类型btype、对应的当前薪水情况salary以及奖金金额bonus。 bonus类型btype为1其奖金为薪水salary的10%，btype为2其奖金为薪水的20%，其他类型均为薪水的30%。 当前薪水表示to_date='9999-01-01'**

```sql
SELECT emp.emp_no, emp.first_name, emp.last_name, eb.btype, sa.salary,
       (CASE eb.btype
             WHEN 1 THEN sa.salary*0.1 
             WHEN 2 THEN sa.salary*0.2
             ELSE sa.salary*0.3
        END) AS bonus
FROM employees AS emp INNER JOIN emp_bonus AS eb ON emp.emp_no = eb.emp_no
                      INNER JOIN salaries AS sa ON emp.emp_no = sa.emp_no AND sa.to_date='9999-01-01';

```

**59. 按照salary的累计和running_total，其中running_total为前两个员工的salary累计和，其他以此类推。 ***

```sql
//窗口函数方法
SELECT emp_no, salary, 
       SUM(salary) OVER (order by emp_no) AS running_total
FROM salaries
WHERE to_date = '9999-01-01';

//联结表写法
SELECT sa2.emp_no, sa2.salary, SUM(sa1.salary) AS running_total
FROM salaries AS sa1 INNER JOIN salaries AS sa2
ON sa1.emp_no <= sa2.emp_no
WHERE sa1.to_date = "9999-01-01" AND sa2.to_date = "9999-01-01"
GROUP BY sa2.emp_no;

```

**60. 对于employees表中，给出奇数行的first_name**

思路：有多少个大于等于e2.first_name的记录的个数就是e2.first_name的行号，比如：

如果 e1.first_name 是第一位，那 e2.first_name 只有1个，就是 e1.first_name 本身，1%2=1；
如果 e1.first_name 排在第二位，就有它和比它小的这2个e2.first_name，2%2=0，所以不选，
以此类推。

```sql
SELECT e1.first_name FROM employees e1
WHERE (
    SELECT count(*) FROM employees e2
    WHERE e1.first_name >= e2.first_name
) % 2 = 1;

```


*/
































