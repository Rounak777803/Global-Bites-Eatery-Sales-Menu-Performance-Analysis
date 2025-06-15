select * from menu_items;

-- 1. write a query to find the number of items on the menu --
select count(distinct item_name)
from menu_items 
;

-- 2. What are the least and most expensive items on the menu? --
SELECT item_name, price
FROM (
    SELECT
        item_name,
        price,
        RANK() OVER (ORDER BY price DESC) as rnk_desc,
        RANK() OVER (ORDER BY price ASC) as rnk_asc
    FROM menu_items
) AS ranked_items
WHERE rnk_desc = 1 OR rnk_asc = 1;

-- 3. How many Italian dishes are on the menu? What are the least and most expensive Italian dishes on the menu? -- 
select  count(category) as Italian_dishes
from menu_items 
where category = "Italian" 
;

select item_name, category, price 
from (
	select item_name, category, price,
    rank() over(order by price desc) as rank_desc,
    rank() over(order by price asc) as rank_asc
    from menu_items
    where category = "Italian" 
    ) as Italian_dishes_rank
where rank_desc = 1 or rank_asc = 1 
;
    
-- 4. How many dishes are in each category? What is the average dish price within each category? -- 
select  category, count(item_name)as No_dishes, round(avg(price),1) AS Avg_price
from menu_items
group by category 
;


-- 5. View the order_details table. What is the date range of the table? --
select * from order_details;

select item_id, min(order_date) as Start_order_date, max(order_date) as present_order_date
from order_details
group by item_id
limit 1
;

-- 6. How many orders were made within this date range? How many items were ordered within this date range? --
SELECT
    MIN(order_date) AS Start_order_date,
    MAX(order_date) AS present_order_date,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(item_id) AS total_items_ordered
FROM
    order_details;
    
-- 7. Which orders had the most number of items? --
select order_id, count(item_id) as Num_items
from order_details
group by order_id
order by Num_orders desc
limit 1 
;

-- 8. How many orders had more than 12 items? --
select count(order_id)  Order_num
from
(select order_id, count(item_id) as Num_items
from order_details
group by order_Id
having num_items > 12 )
as Num_orders
;


-- 9. Combine the menu_items and order_details tables into a single table --
select *
from  order_details 
left join  menu_items
on menu_items.menu_item_id = order_details.item_id
;

-- 10. What were the least and most ordered items? What categories were they in? --
select item_name, category, count(order_id) as num_purchase
from order_details as OD
left join menu_items as MI
on MI.menu_item_id = OD.item_id 
group by item_name, category
order by num_purchase desc
;

-- 11. What were the top 5 orders that spent the most money? --
select order_id, sum(price) as Spent_price
from order_details as OD
left join menu_items as MI
on OD.item_id = MI.menu_item_id 
group by order_id
order by Spent_price desc
limit 5 
;

-- 12. View the details of the highest spend order. Which specific items were purchased? -- 
select category,  count(item_id)as num_items
from order_details as OD
left join menu_items as MI
on OD.item_id = MI.menu_item_id 
where order_id = 440
group by  category
;

-- 13. View the details of the top 5 highest spend orders --
select category, order_id,  count(item_id)as num_items
from order_details as OD
left join menu_items as MI
on OD.item_id = MI.menu_item_id 
where order_id in (440, 2075, 1957, 330, 2675)
group by  category, order_id
order by order_id 
;


-- 14. View the highest selling category of the top 5 highest spend orders -
SELECT
    COALESCE(CAST(OD.order_id AS CHAR), 'Category Total') AS order_or_total,
    SUM(CASE WHEN MI.category = 'Asian' THEN 1 ELSE 0 END) AS Asian,
    SUM(CASE WHEN MI.category = 'American' THEN 1 ELSE 0 END) AS American,
    SUM(CASE WHEN MI.category = 'Italian' THEN 1 ELSE 0 END) AS Italian,
    SUM(CASE WHEN MI.category = 'Mexican' THEN 1 ELSE 0 END) AS Mexican
FROM
    order_details AS OD
LEFT JOIN
    menu_items AS MI ON OD.item_id = MI.menu_item_id
WHERE
    OD.order_id IN (440, 2075, 1957, 330, 2675)
GROUP BY
    OD.order_id WITH ROLLUP
ORDER BY
    CASE WHEN OD.order_id IS NULL THEN 1 ELSE 0 END, 
    OD.order_id; 
