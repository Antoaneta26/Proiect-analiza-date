select 
ad_date ,campaign_id ,
sum(spend) as total_spend,
sum(impressions) as total_impressions,
sum(clicks) as total_clicks,
sum(value) as total_value,
sum(spend) /sum(clicks)as cpc,
sum(spend) /sum(impressions) *1000 as cpm,
sum(clicks)::numeric/sum(impressions) as ctr,
sum(value)::numeric*sum(spend) /sum(spend) as romi
from facebook_ads_basic_daily fabd 
where clicks >0 and impressions >0 and spend >0
group by ad_date ,campaign_id 
order by ad_date desc ;

select 
campaign_id ,
sum(spend) as total_spend,
sum(value)::numeric*sum(spend) /sum(spend) as romi
from facebook_ads_basic_daily fabd 
where spend >0
group by 1
having sum(spend) >=500000
order by 3 desc 