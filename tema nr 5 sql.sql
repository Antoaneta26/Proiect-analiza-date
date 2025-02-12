with all_ads_data as (select
fabd.ad_date,
fabd.url_parameters,
fc.campaign_name,
fa.adset_name,
fabd.spend,
fabd.impressions,
fabd.reach,
fabd.clicks,
fabd.leads,
fabd.value
from facebook_ads_basic_daily fabd
left join facebook_adset fa
on fabd.adset_id = fa.adset_id
left join facebook_campaign fc
on fc.campaign_id = fabd.campaign_id
union all
select
ad_date,
url_parameters,
campaign_name,
adset_name,
spend,
impressions,
reach,
clicks,
leads,
value
from google_ads_basic_daily gabd
)
select
ad_date,
case
	when lower (substring(url_parameters, 'utm_campaign([^\&]+)')) = 'nan' then null
	when lower (substring (url_parameters, 'utm_campaign([^\&]+)')) ='' then null
	else decode_url_part3((substring( url_parameters,'utm_campaign([^\&]+)')))
end as utm_campaign,
/*sum(spend) as total_spend,
 sum(impressions) as total_impressions,
 sum(reach) as total_reach,
 sum(clicks) as toatal_clicks,
 sum(value) as total_value,
 sum(value) as total_value,*/
 case 
 	when sum(clicks)> 0 then sum(spend)/ sum(clicks) 
 	end as cpc,
 	case 
	when sum(impressions)> 0 then sum(spend)::numeric / sum(impressions)*1000
	end as cpm,
	case 
 	when sum(impressions)> 0 then sum(clicks):: numeric / sum(impressions) *100
 	end as ctr,
 	case 
	when sum(spend)> 0 then round(sum(value)::numeric-sum(spend))/ sum(spend) *100
	end as romi
	from all_ads_data
	where spend >0
	group by 1,2
	order by ad_date;
 	
 
 
 



