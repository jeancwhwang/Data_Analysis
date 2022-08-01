/*
Reformat the Data:
--Reformat the final_assignments_qa by using Union
--Filling in any missing values with a placeholder of the appropriate data type.
*/

SELECT  
      item_id, 
      test_a as test_assignment,
      (case when test_a is not null then 'test_a' else null end) as test_number,
      (case when test_a is not null then '2013-01-05 00:00:00'::timestamp else null end) as test_start_date 
FROM dsv1069.final_assignments_qa
UNION 
SELECT 
      item_id, 
      test_b as test_assignment,
      (case when test_b is not null then 'test_b' else null end) as test_number,
      (case when test_b is not null then '2013-01-05 00:00:00'::timestamp else null end) as test_start_date 
FROM dsv1069.final_assignments_qa
UNION 
SELECT 
      item_id, 
      test_c as test_assignment,
      (case when test_c is not null then 'test_c' else null end) as test_number,
      (case when test_c is not null then '2013-01-05 00:00:00'::timestamp else null end) as test_start_date 
FROM dsv1069.final_assignments_qa
UNION 
SELECT 
      item_id, 
      test_d as test_assignment,
      (case when test_d is not null then 'test_d' else null end) as test_number,
      (case when test_d is not null then '2013-01-05 00:00:00'::timestamp else null end) as test_start_date 
FROM dsv1069.final_assignments_qa
UNION 
SELECT 
      item_id, 
      test_e as test_assignment,
      (case when test_e is not null then 'test_e' else null end) as test_number,
      (case when test_e is not null then '2013-01-05 00:00:00'::timestamp else null end) as test_start_date 
FROM dsv1069.final_assignments_qa
UNION 
SELECT 
      item_id, 
      test_f as test_assignment,
      (case when test_f is not null then 'test_f' else null end) as test_number,
      (case when test_f is not null then '2013-01-05 00:00:00'::timestamp else null end) as test_start_date 
FROM dsv1069.final_assignments_qa;

/*
Compute Order Binary:
--Use the final_assignments table to calculate the order binary for the 30 day window after the test assignment for item_test_2 
*/

SELECT 
      test_assignment as test_assignment,
      count(item_id) as number_of_items,
      sum(orders_binary) as item_ordered_30d_binary

FROM (SELECT 
            item_level.item_id as item_id,
            item_level.test_assignment as test_assignment,
            item_level.test_number as test_number,
            max (case when (item_level.paid_at > item_level.test_start_date 
                and date_part('day', item_level.paid_at-item_level.test_start_date)<=30) then 1 else 0 end) as orders_binary
        
       FROM (SELECTt 
                    final_assignments.item_id as item_id,
                    final_assignments.test_assignment as test_assignment,
                    final_assignments.test_number as test_number, 
                    final_assignments.test_start_date as test_start_date,
                    orders.paid_at as paid_at
              FROM dsv1069.final_assignments 
              LEFT JOIN dsv1069.orders 
              ON final_assignments.item_id=orders.item_id) as item_level  
      GROUP BY,2,3) AS order_level
WHERE test_number='item_test_2'
GROUP BY 1;

/*
Compute View Item Metrics:
--Use the final_assignments table to calculate the view binary and average views for the 30 day window after the test assignment for item_test_2 
*/

SELECT 
      test_assignment as test_assignment, 
      count(item_id) as number_of_items,
      sum(views_after_event_binary) as numbers_of_views_after_event_binary_30d,
      avg(views_after_event) as avg_views_after_event_30d
      
FROM (SELECT 
         test_level.item_id as item_id,
         test_level.test_assignment as test_assignment,
         test_level.test_number as test_number,
         max(case when view_item_level.event_time>test_level.test_start_date 
              and date_part('day',view_item_level.event_time-test_level.test_start_date)<=30 then 1 else 0 end) as views_after_event_binary,
         count(distinct case when view_item_level.event_time>test_level.test_start_date 
              and date_part('day',view_item_level.event_time-test_level.test_start_date)<=30 then test_level.item_id else null end) as views_after_event  
    FROM           (SELECT 
                          final_assignments.item_id as item_id,
                          final_assignments.test_assignment as test_assignment,
                          final_assignments.test_number as test_number, 
                          final_assignments.test_start_date as test_start_date
                    FROM dsv1069.final_assignments) as test_level 
                    LEFT JOIN 
                    (SELECT 
                          event_id,
                          event_name,
                          event_time,
                          (case when parameter_name='item_id' then parameter_value::int else null end) as item_id
                    FROM dsv1069.events 
                    WHERE event_name='view_item') as view_item_level
                    ON test_level.item_id=view_item_level.item_id 
    GROUP BY 1,2,3) AS view_item_30d
WHERE test_number='item_test_2'
GROUP  BY 1;
