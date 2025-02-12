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
),
monthly_stats as(
select
date_trunc('month', ad_date) as ad_month,
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
	),
	monthly_stats_with_changes as(
	select 
	*,
	lag (romi)over (partition by utm_campaign order by ad_month desc )as previous_month_romi,
	lag (ctr)over (partition by utm_campaign order by ad_month desc ) as previous_month_ctr,
	lag (cpm)over (partition by utm_campaign order by ad_month desc) as previous_month_cpm
	from monthly_stats
	)
	select
	*,
	case
		when previous_month_romi > 0 then round ((romi::numeric/ previous_month_romi -1),2)
		when previous_month_romi = 0 and romi > 0 then 1
	end as romi_change,
	case 
		when previous_month_ctr > 0 then round ((ctr::numeric/previous_month_ctr -1),2)
		when previous_month_ctr = 0 and romi > 0 then 1
	end as ctr_change,
	case 
		when previous_month_cpm > 0 then round ((cpm::numeric/previous_month_cpm -1),2)
		when previous_month_cpm = 0 and cpm > 0 then 1
	end as cpm_change
	from monthly_stats_with_changes;
	
	
	
 	
 
 
 



