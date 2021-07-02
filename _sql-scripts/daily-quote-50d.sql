select
	StockCode,
	avg(ClosePrice) as SMA50, max(ClosePrice) as ClosePrice50D
from
	(select *, ROW_NUMBER() over(partition by StockCode order by QuoteDate desc) as RowNumber
	from DailyQuote as DailyQuoteWithRowNumber) as DailyQuoteWithRowNumber
where RowNumber <= 50
group by StockCode