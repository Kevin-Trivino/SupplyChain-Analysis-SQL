# SupplyChain-Analysis-SQL

This supply chain dataset provides a comprehensive view of the company's order and distribution processes, allowing for in-depth analysis and optimization of various aspects of the supply chain, from procurement and inventory management to sales.

After inital exploration of data looking for trends in different metrics such as units sold, revenue, gross profit etc. decided to focus on fulfillment times and ways to imporve.


## SUmmary of insights 
Some insights found 
most products have similar order quanitties between 120-200

avg order fullment time is 20 days with the minimum being 3 nd the maximum being 38
  avg for each product range between 18 and 22 days


warehouses all have similar average fullfillment times for all products at aound 20 days

## Main Takeaway
There were no major differences or trends in terms of fullfilment time or revenue across single dimesions such as warehouse, time of year, customer etc.

However when splitting fulfillment time across two dimensions, warehouse and product, it is clear that some warehouses manage to fulfill orders much faster than other warehouses. This seems like an area to focus on to improve the supply chain operations. There may be several reasons why certian warehouses are able to consistnatly fulfill orders faster than other warhouses and this area can be investigated furthur to improve operatioins and cusomer satisfaction. For the purpose of this porject I manaeged to identifyt he top five products witht heighest average fullfilment time an matched them with the warehouses with the lowest fullfillment time for ech product. This provides a steppign stone for furthur investigation int owhy a warehouse may be providing more satisfacory fullment times for each product and which specific warehouses to focus on.

identified top five products in each warehouse with highest fullment times
then identidied which warhouses are able to fullfil those orders at the smallest average time
   possinly investigate how they ar able to fullfil these orders in a smaller time and replicate in other warehouses
