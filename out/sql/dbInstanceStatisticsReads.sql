-- Copyright © 2018 IDERA, Inc. All rights reserved.

-- Database Statistics by Top 5 Instances (Reads [MB])
set transaction isolation level read uncommitted

declare
	@HistoryInMinutes int = 240, --4 hours
	@BeginDateTime datetime,
	@EndDateTime datetime,
	@TopN int = 5

select @EndDateTime = (select max(UTCCollectionDateTime) from dbo.ServerStatistics)

if (@HistoryInMinutes is null)
	select @BeginDateTime = @EndDateTime
else
	select @BeginDateTime = dateadd(n, -@HistoryInMinutes, @EndDateTime)

select TOP (@TopN)
	[SQL Instance] = ms.InstanceName,
	[Max Reads/sec] = round(max(ds.BytesRead/1024),0),
	[Avg Reads/sec] = round(avg(ds.BytesRead/1024),0)
from dbo.DatabaseStatistics ds
	inner join dbo.SQLServerDatabaseNames dn on dn.DatabaseID = ds.DatabaseID
	inner join dbo.MonitoredSQLServers ms on ms.SQLServerID = dn.SQLServerID
--where UTCCollectionDateTime between @BeginDateTime and @EndDateTime
group by ms.InstanceName
order by [Avg Reads/sec] desc