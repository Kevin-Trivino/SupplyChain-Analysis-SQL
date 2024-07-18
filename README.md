# SupplyChain-Analysis-SQL

This supply chain dataset provides a comprehensive view of the company's order and distribution processes, allowing for in-depth analysis and optimization of various aspects of the supply chain, from procurement and inventory management to sales.

After initial exploration of the data, looking for trends in different metrics such as units sold, revenue, gross profit, etc., I decided to focus on fulfillment times and ways to improve.


## Summary of insights 
- most products have similar order quantities between 120 and 200.
- avg time for each product range between 18 and 22 days
- total order per warehouse did not affect fulfillment time.
- warehouses all have similar average fulfillment times for all products at around 20 days.

## Main Takeaway
There were no major differences or trends in terms of fulfillment time or revenue across single dimensions such as warehouse, time of year, customer, etc.

However, when splitting fulfillment time across two dimensions, warehouse and product, it is clear that some warehouses manage to fulfill orders much faster than other warehouses. This seems like an area to focus on to improve supply chain operations. There may be several reasons why certain warehouses are able to consistently fulfill orders faster than others, and this area can be investigated further to improve operations and customer satisfaction. For the purpose of this project, I managed to identify the top five products with the highest average fulfillment time and match them to warehouses with the lowest fulfillment time for each product. This provides a stepping stone for further investigation into why a warehouse may be providing more satisfactory fulfillment times for each product and which specific warehouses to focus on.
