declare @quote_date as datetime = '08/24/2023'

select pse_latest.stock_code, quote_date, close_price, highest_close_50, sma_50, sma_100, average_value_50 from
	(select stock_code, quote_date, close_price from
		(select *, ROW_NUMBER() over(partition by stock_code order by quote_date desc) as stock_row
		from pse_daily_quote where quote_date <= @quote_date) as pse_daily_quote_extended
	where stock_row = 1) as pse_latest
inner join
	(select stock_code, AVG(close_price) as sma_50, MAX(close_price) as highest_close_50, AVG(value) average_value_50 from
		(select *, ROW_NUMBER() over(partition by stock_code order by quote_date desc) as stock_row
		from pse_daily_quote where quote_date <= @quote_date) as pse_daily_quote_extended
	where stock_row <= 50
	group by stock_code) as pse_fifty
on pse_latest.stock_code = pse_fifty.stock_code
inner join
	(select stock_code, AVG(close_price) as sma_100 from
		(select *, ROW_NUMBER() over(partition by stock_code order by quote_date desc) as stock_row
		from pse_daily_quote where quote_date <= @quote_date) as pse_daily_quote_extended
	where stock_row <= 100
	group by stock_code) as pse_one_hundred
on pse_latest.stock_code = pse_one_hundred.stock_code
where sma_50 > sma_100 and close_price = highest_close_50