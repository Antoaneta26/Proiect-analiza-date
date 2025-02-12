with all_ads_data as (select
fc.campaign_name,
fa.adset_name,
fabd.spend,
fabd.value
from facebook_ads_basic_daily fabd
left join facebook_campaign fc
on fabd.campaign_id = fc.campaign_id
left join facebook_adset fa
on fabd.adset_id = fa.adset_id
union all
select
campaign_name,
adset_name,
spend,
value
from google_ads_basic_daily gabd
)
select
campaign_name ,
adset_name,
sum(spend) as total_spend,
( sum(value)::numeric -sum(spend)::numeric) /sum(spend)*100 as romi
from all_ads_data
where spend > 0
group by 1,2
having sum(spend) > 500000
order by 4 desc 
limit 1;