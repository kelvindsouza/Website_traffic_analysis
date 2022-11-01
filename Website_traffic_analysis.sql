-- Traffic Source Analysis
-- TOP TRAFFIC SOURCES

select 
	website_sessions.utm_content , 
	count(distinct website_sessions.website_session_id) as session_id, 
    count(distinct orders.order_id) as orders ,
    count(distinct orders.order_id) / count(distinct website_sessions.website_session_id) as session_to_order_conversion_rate
from website_sessions 
	left join orders on website_sessions.website_session_id = orders.website_session_id
where website_sessions.website_session_id between 1000 and 2000
group by website_sessions.utm_content
order by 2 desc;

-- Total Sessions Breakdown by UTM_Source , UTM_campaign , HTTP_Refer

select 
	utm_source,
	utm_campaign,
    http_referer,
    count(distinct website_session_id) as sessions
from website_sessions
where
	created_at < '2012-04-12'
group by 	
	utm_source,
	utm_campaign,
    http_referer
order by sessions desc;

-- Since gsearch , Nonbrand is driving higher sales check the conversion rate from sessions to count of orders

select 
	count(distinct website_sessions.website_session_id) as session_id ,
    count(distinct orders.order_id) as orders,
    count(distinct orders.order_id) / count(distinct website_sessions.website_session_id) as Conversion_rate_from_sessions_to_orders
from website_sessions 
	left join orders on website_sessions.website_session_id = orders.website_session_id
where website_sessions.utm_source = 'gsearch' and website_sessions.utm_campaign = 'nonbrand' and website_sessions.created_at  < '2012-04-12'; 


-- Since the Conversion rate is very low the team has bid down on gsearch,nonbrand so post april 4 and till may 10 chech the session trend

select 
	min(date(created_at)) as Start_day_of_the_week,
    count(distinct website_session_id) as sessions
from website_sessions
where 
	created_at between '2012-04-12' and '2012-05-10' and
	utm_source = 'gsearch' and utm_campaign = 'nonbrand'
group by 
	year(created_at),
    week(created_at)
order by 1 asc;


-- Check the Conversion rate for Desktop and Mobile Users

select 
	website_sessions.device_type,
    count( distinct website_sessions.website_session_id) as sessions,
    count( distinct orders.order_id) as orders ,
    count( distinct orders.order_id)  / count( distinct website_sessions.website_session_id) as Conversion_rate
from website_sessions 
	left join orders on website_sessions.website_session_id = orders.website_session_id
where 
	website_sessions.created_at < '2012-05-11' and 
    utm_source = 'gsearch' and utm_campaign = 'nonbrand'
group by 
	1 ;
    
-- Device Level Analysis from April 10 to June 09 

select 
	min(date(website_sessions.created_at)) as Start_day_of_the_week,
	count(case when website_sessions.device_type = 'mobile' then website_sessions.website_session_id else null end)  as mobile_session,
    count(case when website_sessions.device_type = 'desktop' then website_sessions.website_session_id else null end)  as desktop_session
from website_sessions 
	left join orders on website_sessions.website_session_id = orders.website_session_id
where 
	website_sessions.created_at  between '2012-04-15' and  '2012-06-09' and 
    utm_source = 'gsearch' and utm_campaign = 'nonbrand'
group by 
	year(website_sessions.created_at) ,
    week(website_sessions.created_at) ;


-- Analysing Website Performence
-- Most Viewed Webpage URL

select 
	pageview_url,
    count(distinct website_pageview_id) as Session_count_for_Each_URL
from website_pageviews
where created_at < '2012-06-09'
group by 
	pageview_url
order by 2 desc;


-- Top Entries of Landing Page

create temporary table landing_pages
select
	website_session_id ,
	min(website_pageview_id) as landing_id
from website_pageviews
group by website_session_id;

 
select 
	website_pageviews.pageview_url, 
    count(distinct landing_pages.landing_id) as Count_of_landing_page
from website_pageviews 
	left join landing_pages on website_pageviews.website_pageview_id = landing_pages.landing_id
where website_pageviews.created_at < '2012-06-12'
group by 
	website_pageviews.pageview_url
Having Count_of_landing_page !=0;


-- Landing Page Analysis
-- Bounce Rate 

 -- Since the landing page is majorly towards /home page , check the Bounce rate for that particular page
 
 -- Check the Landing pageview  for each session 
 -- connect the Page view id to URL
 -- Check for each session the the count of pageviews , ignore the count if its more than one 
 -- with the count of page view ID and count of Bounce session ID check the conversion rate
 select * from website_pageviews;
 
 
create temporary table landing_pageview
select 
	website_session_id,
    min(website_pageview_id) as landing_pageview_id
from website_pageviews 
group by website_session_id;


select * from landing_pageview;

create temporary table landing_page_url
select 
	landing_pageview.website_session_id, 
    website_pageviews.pageview_url as landing_page
from landing_pageview 
	left join website_pageviews 
    on landing_pageview.landing_pageview_id = website_pageviews.website_pageview_id
where website_pageviews.created_at < '2012-06-14' and website_pageviews.pageview_url = '/home';

select * from landing_page_url;

create temporary table bounced_sessions
select 
	landing_page_url.website_session_id ,
    landing_page_url.landing_page ,
    count(  website_pageviews.website_session_id) as total_session_for_page_view
from landing_page_url 
	left join website_pageviews 
    on landing_page_url.website_session_id = website_pageviews.website_session_id
group by 1 , 2
having 
	count(website_pageviews.website_session_id) = 1;
    
select * from bounced_sessions;

select 
	count(distinct landing_page_url.website_session_id) as total_home_landing_page,
    count( bounced_sessions.total_session_for_page_view) as total_bounced_home_landing_page ,
    count( total_session_for_page_view) / count(distinct landing_page_url.website_session_id) as CVR_from_bounced_to_total_session
from bounced_sessions
	right join landing_page_url 
    on bounced_sessions.website_session_id = landing_page_url.website_session_id;
    
    
-- Analysing Landing page
-- since the bounce rate is high for home page , we have setup new landing page just to check if the bounce rate is better for new lading page 


create temporary table landing_pageview_test
select 
	website_session_id,
    min(website_pageview_id) as landing_pageview_id
from website_pageviews 
group by website_session_id;


create temporary table landing_page_url_test
select 
	landing_pageview_test.website_session_id, 
    website_pageviews.pageview_url as landing_page
from landing_pageview_test
	left join website_pageviews 
    on landing_pageview_test.landing_pageview_id = website_pageviews.website_pageview_id
where website_pageviews.created_at between '2012-06-14' and  '2012-07-28' ;


create temporary table bounced_sessions_test
select 
	landing_page_url_test.website_session_id ,
    landing_page_url_test.landing_page ,
    count( website_pageviews.website_session_id) as total_session_for_page_view
from landing_page_url_test
	left join website_pageviews 
    on landing_page_url_test.website_session_id = website_pageviews.website_session_id
group by 1 , 2
having 
	count(website_pageviews.website_session_id) = 1;
    

select 
	landing_page_url_test.landing_page,
	count(distinct landing_page_url_test.website_session_id) as total_home_landing_page,
    count( bounced_sessions_test.total_session_for_page_view) as total_bounced_home_landing_page ,
    count( bounced_sessions_test.total_session_for_page_view) / count(distinct landing_page_url_test.website_session_id) as CVR_from_bounced_to_total_session
from bounced_sessions_test
	right join landing_page_url_test
    on bounced_sessions_test.website_session_id = landing_page_url_test.website_session_id
group by 
	1;
    
-- Apply Trend analysis for home and lander page to check how the bounce rate is evolving over time (Keep the Volume to gsearch , Nonbrand)

create temporary table landing_pageview_trend_analysis
select 
	website_pageviews.website_session_id,
    min(website_pageviews.website_pageview_id) as landing_pageview_id ,
    count(distinct website_pageviews.website_pageview_id) as count_pageviews
from website_sessions
	left join website_pageviews 
    on website_pageviews.website_session_id = website_sessions.website_session_id
where website_sessions.created_at > '2012-06-01'
	and website_sessions.created_at < '2012-08-31'
	and website_sessions.utm_source = 'gsearch' 
	and website_sessions.utm_campaign ='nonbrand'
group by website_pageviews.website_session_id;



create temporary table website_landingpage_created_at
select 
	landing_pageview_trend_analysis.website_session_id ,
    landing_pageview_trend_analysis.landing_pageview_id,
    landing_pageview_trend_analysis.count_pageviews,
    website_pageviews.pageview_url,
    website_pageviews.created_at
from landing_pageview_trend_analysis
	left join website_pageviews
    on landing_pageview_trend_analysis.website_session_id = website_pageviews.website_session_id;
    
    
select 
	min(date(created_at)) as start_of_the_week,
    count(distinct case when pageview_url = '/home' then website_session_id else null end) as home_session ,
	count(distinct case when pageview_url = '/lander-1' then website_session_id else null end) as lander_session
from website_landingpage_created_at
group by 
	year(created_at),
    week(created_at);
	
-- Conversion rate in each steps towards buying the product

-- use flag to identify pageviews in each of the URL
-- using MAX combine the session_id flags 
-- Using Count combine the entire flag range to get the overall number of rates in each pageview

create temporary table page_clicks
select 
	website_session_id,
    max(products_page) as clicked_on_products_page,
    max(original_fuzzy_page) as clicked_on_original_fuzzy_page ,
    max(cart_page) as clicked_on_cart_page ,
    max(shipping_page) as clicked_on_shipping_page,
    max(billing_page) as clicked_on_billing_page ,
    max(thank_you_page) as clicked_on_thank_you_page  
from 
(select 
	website_sessions.website_session_id ,
    website_pageviews.pageview_url ,
    case when pageview_url = '/products' then 1 else 0 end  as products_page,
    case when pageview_url = 'the-original-mr-fuzzy' then 1 else 0 end as original_fuzzy_page ,
    case when pageview_url = '/cart' then 1 else 0 end as cart_page,
    case when pageview_url = '/shipping' then 1 else 0 end as shipping_page, 
    case when pageview_url = '/billing' then 1 else 0 end as billing_page, 
    case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thank_you_page 
from website_sessions
	left join website_pageviews 
    on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at > '2012-08-05'
	and website_sessions.created_at < '2012-09-05'
    and utm_source = 'gsearch'
    and utm_campaign = 'nonbrand'
) as pageview_flag

group by 
	1;
    
    
select 
	count(distinct case when clicked_on_products_page =1 then website_session_id else 0 end) as product_page ,
	count(distinct case when clicked_on_original_fuzzy_page =1 then website_session_id else 0 end) as mr_original_fuzzy_page ,
    count(distinct case when clicked_on_cart_page =1 then website_session_id else 0 end) as cart_page,
    count(distinct case when clicked_on_shipping_page=1 then website_session_id else 0 end) as shipping_page,
    count(distinct case when clicked_on_billing_page =1 then website_session_id else 0 end) as billing_page,
    count(distinct case when clicked_on_thank_you_page=1 then website_session_id else 0 end) as thankyou_page 
from 
	page_clicks;