declare @quote_date as datetime = '08/20/2021'

select Latest.Symbol, QuoteDate, ClosePrice, HighestClose50, SMA50, SMA100, AverageValue50 from
	(select Symbol, QuoteDate, ClosePrice from
		(select *, ROW_NUMBER() over(partition by Symbol order by QuoteDate desc) as RowNumber
		from PseQuote where QuoteDate <= @quote_date) as PseQuoteWithRowNumber
	where RowNumber = 1) as Latest
inner join
	(select Symbol, AVG(ClosePrice) as SMA50, MAX(ClosePrice) as HighestClose50, AVG(Value) AverageValue50 from
		(select *, ROW_NUMBER() over(partition by Symbol order by QuoteDate desc) as RowNumber
		from PseQuote where QuoteDate <= @quote_date) as PseQuoteWithRowNumber
	where RowNumber <= 50
	group by Symbol) as Fifty
on Latest.Symbol = Fifty.Symbol
inner join
	(select Symbol, AVG(ClosePrice) as SMA100 from
		(select *, ROW_NUMBER() over(partition by Symbol order by QuoteDate desc) as RowNumber
		from PseQuote where QuoteDate <= @quote_date) as PseQuoteWithRowNumber
	where RowNumber <= 100
	group by Symbol) as OneHundred
on Latest.Symbol = OneHundred.Symbol
where SMA50 > SMA100 and ClosePrice = HighestClose50