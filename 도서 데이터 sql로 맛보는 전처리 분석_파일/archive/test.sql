use classicmodels;

select orderNumber
from classicmodels.orderdetails;

select *
from classicmodels.orderdetails
where priceEach between 30 and 50;

select *
from classicmodels.orderdetails
where priceEach >= 30;

select employees.employeeNumber
from classicmodels.employees
where reportsTo is null;

-- is not null
select employees.employeeNumber
from classicmodels.employees
where reportsTo is not null;

select country,
       city,
       count(customerNumber) cus
from classicmodels.customers
group by country,
         city;


select *
from orders a
         left join customers b
                   on a.customerNumber = b.customerNumber
limit 3;


select a.customerNumber, a.country
from classicmodels.customers a
         left join orders b
                   on a.customerNumber = b.customerNumber
where country in ('USA')
;

select orders.orderNumber, country
from customers
         inner join orders
                    on orders.customerNumber = orders.customerNumber
where country in ('USA')
;

select customers.country,
       case
           when country in ('USA', 'Canada') then 'North America'
           ELSE
               'ohers' end as region
from customers;



select case
           when country in ('USA', 'Canada') then 'NORTH AMERICA'
           else 'OTHERS' end as region,
       count(customerNumber)    cust
from classicmodels.customers
group by case
             when country in ('USA', 'Canada') then 'NORTH AMERICA'
             else 'OTHERS' END;

-- v2 group by 절이 간단해진걸 볼 수 있다. group by 첫번쨰 칼럼을 그륩핑 하겠다는 뜻이다.
select case
           when country in ('USA', 'Canada') then 'NORTH AMERICA'
           else 'OTHERS' end as region,
       count(customerNumber)    cust
from customers
group by 1
;

-- 일별 매출액
select a.orderDate,
       priceEach + quantityOrdered
from orders a
         left join orderdetails B
                   on a.orderNumber = b.orderNumber
;
select a.orderDate,
       sum(priceEach * quantityOrdered) as sales
from orders a
         left join orderdetails b
                   on a.orderNumber = b.orderNumber
group by 1
order by 1;


select substr('ABCDE', 2, 3);

select count(orders.orderNumber)          n_orders,
       count(distinct orders.orderNumber) n_orders_dis
from orders;

select orders.orderDate,
       count(distinct orders.customerNumber) n_purcharaser,
       count(orders.orderNumber)             n_orders
from orders
group by 1
order by 1;

select substr(A.orderdate, 1, 4),
       count(distinct a.customernumber)        n_purcharser,
       sum(b.priceEach * b.quantityOrdered) as sales
from orders a
         left join orderdetails b
                   on a.orderNumber = b.orderNumber
group by 1
order by 1;

select substr(a.orderdate, 1, 4)                                     YY,
       count(distinct a.orderNumber)                                 m_purchaser,
       sum(orderdetails.priceEach * orderdetails.quantityOrdered) as sales
from orders a
         left join orderdetails
                   on a.orderNumber = orderdetails.orderNumber
group by 1
order by 1;

select substr(a.orderdate, 1, 4)                                      YY,
       count(distinct a.customerNumber)                               n_purchaser,
       sum(orderdetails.priceEach * orderdetails.quantityOrdered),
       sum(orderdetails.priceEach) / count(distinct a.customerNumber) amv
from orders a
         left join orderdetails
                   on a.orderNumber = orderdetails.orderNumber
group by 1
order by 1

-- 건당구매
select substr(a.orderdate, 1, 4)                                   YY,
       count(distinct a.customerNumber)                            n_purchaser,
       sum(orderdetails.priceEach * orderdetails.quantityOrdered),
       sum(orderdetails.priceEach) / count(distinct a.orderNumber) atv
from orders a
         left join orderdetails
                   on a.orderNumber = orderdetails.orderNumber
group by 1
order by 1
;

-- 그륩별 구매 지표 3중조인
select customers.country,
       case
           when country in ('USA', 'Canada') then 'North America'
           ELSE
               'ohers' end as region
from customers;

select case
           when country in ('USA', 'Canada') then 'North America'
           else 'Otheres' end country_grp
from customers;
#sum(b.priceEach * b.quantityOrdered) sales 총매출 구한후 order - orderdetails - customers 순으로 조인을 진행한다.
select c.country,
       c.city,
       sum(b.priceEach * b.quantityOrdered) sales
from orders a
         left join orderdetails b
                   on a.orderNumber = b.orderNumber
         left join customers c
                   on a.customerNumber = c.customerNumber
group by 1, 2
order by 3
;


select case
           when country in ('USA', 'Canada') then 'North America'
           else 'Otheres' end                                     country_grp,
       sum(orderdetails.priceEach * orderdetails.quantityOrdered) sales
from orders a
         left join orderdetails
                   on a.orderNumber = orderdetails.orderNumber
         left join customers c
                   on a.customerNumber = c.customerNumber
group by 1
order by 2 desc;



select name,
       goals,
       rank() over (order by GOALS DESC)       as 'RANK',
       dense_rank() over (order by goals desc) as 'DENSE RANK',
       ROW_NUMBER() over (order by goals desc) as 'Rownumber'
from football.players
;

create table classicmodels.stat as
select c.country,
       sum(o.priceEach * o.quantityOrdered) sales
from orders a
         left join classicmodels.orderdetails o on a.orderNumber = o.orderNumber
         join customers c
              on a.customerNumber = c.customerNumber
group by 1
order by 2 desc;

select *
from stat;


-- subquery

select *
from (select country,
             sales, -- 215줄에거 가져온다 sales 총 매출  <=5이하까지
             dense_rank() over (order by sales desc) rnk
      from (select c.country,
                   sum(b.priceEach * b.quantityOrdered) sales
            from orders a
                     left join orderdetails b
                               on a.orderNumber = b.orderNumber
                     left join customers c
                               on a.customerNumber = c.customerNumber
            group by 1) a) a
where rnk <= 5;

-- v2
select *
from (select country,
             sales,
             dense_rank() over (order by sales desc) rnk
      from (select c.country,
                   sum(b.priceEach * b.quantityOrdered) sales
            from orders a
                     left join orderdetails b
                               on a.orderNumber = b.orderNumber
                     left join customers c
                               on a.customerNumber = a.customerNumber
            group by 1) a) a
where rnk <= 5;


-- 구조해석:
# on a.customerNumber =b.customerNumber and substr(a.orderDate,1,4) = substr(b.orderDate,1,4) -1;
-- 해당 부분은 연도 1,4 예:2024를 추출하고 셀프조인으로 b도 같다면 -1을 뺴는 것이다.

select a.customernumber,
       a.orderdate,
       b.customernumber,
       b.orderdate
from orders a
         left join orders b
                   on a.customerNumber = b.customerNumber and substr(a.orderDate, 1, 4) = substr(b.orderDate, 1, 4) - 1;


select c.country,
       substr(a.orderdate, 1, 4)        YY,
       count(distinct a.customernumber) Bu1,
       count(distinct b.customernumber) Bu2,
       count(distinct b.customerNumber) / count(distinct a.customerNumber) -- 고객수 구하기
                                        Retention_RATE
from orders a
         left join orders b
                   on a.customerNumber = b.customerNumber and substr(a.orderDate, 1, 4)
                       = substr(b.orderDate, 1, 4) - 1 -- 비교하고 같은건 1 마이너스 이전연도와 비교
         left join customers c
                   on a.customerNumber = c.customerNumber
group by 1, 2;

create table PRODUCT_SALES as
select d.productName,
       sum(c.quantityOrdered * c.priceEach) sales
from orders a
         left join customers b
                   on a.customerNumber = b.customerNumber
         left join orderdetails c
                   on a.orderNumber = c.orderNumber
         left join products d
                   on c.productCode = d.productCode
where b.country = 'USA'
group by 1;



select *
from (select *,
             row_number() over (order by sales desc) RNK
      from product_sales) a
where rnk <= 5
order by rnk;


-- 유령회원 구하기


select max(orderdate) mx_order
from orders;

select orders.customerNumber,
       max(orderdate) mx_order
from orders
group by 1;

-- datediff(값1 - 값2)
SELECT customerNumber,
       mx_order,
       '2005-06-01',
       DATEDIFF('2005-06-01', mx_order) AS Diff
FROM (SELECT customerNumber,
             MAX(orderDate) AS mx_order
      FROM orders

      GROUP BY customerNumber) AS base;

select *,
       case when diff >= 90 then 'CHURN' else 'NON-CURAN' end cHurn_type
from (select customerNumber,
             mx_order,
             '2005-06-01'                     end_point,
             datediff('2005-06-01', mx_order) diff
      from (select orders.customerNumber,
                   max(orders.orderDate) mx_order
            from orders
            group by 1) base) base;
--
select case when diff >= 90 then '유령회원' ELSE '정회원' end CHURN_TYPE,
       count(distinct customerNumber)                         n_cus
from
    (select customerNumber,Mx_order,
            '2005-06-01' end_point,
     datediff('2005-06-01',mx_order) diff
     from (select customerNumber,max(orders.orderDate)mx_order
           from orders group by 1)Base
            )Base
group by 1;

