declare @quote_date as datetime = '07/30/2021'

select Latest.StockCode, QuoteDate, ClosePrice, HighestClose50, SMA50, SMA100, AverageValue50 from
	(select StockCode, QuoteDate, ClosePrice from
		(select *, ROW_NUMBER() over(partition by StockCode order by QuoteDate desc) as RowNumber
		from DailyQuote where QuoteDate <= @quote_date) as DailyQuoteWithRowNumber
	where RowNumber = 1) as Latest
inner join
	(select StockCode, AVG(ClosePrice) as SMA50, MAX(ClosePrice) as HighestClose50, AVG(Value) AverageValue50 from
		(select *, ROW_NUMBER() over(partition by StockCode order by QuoteDate desc) as RowNumber
		from DailyQuote where QuoteDate <= @quote_date) as DailyQuoteWithRowNumber
	where RowNumber <= 50
	group by StockCode) as Fifty
on Latest.StockCode = Fifty.StockCode
inner join
	(select StockCode, AVG(ClosePrice) as SMA100 from
		(select *, ROW_NUMBER() over(partition by StockCode order by QuoteDate desc) as RowNumber
		from DailyQuote where QuoteDate <= @quote_date) as DailyQuoteWithRowNumber
	where RowNumber <= 100
	group by StockCode) as OneHundred
on Latest.StockCode = OneHundred.StockCode
where SMA50 > SMA100 and ClosePrice = HighestClose50