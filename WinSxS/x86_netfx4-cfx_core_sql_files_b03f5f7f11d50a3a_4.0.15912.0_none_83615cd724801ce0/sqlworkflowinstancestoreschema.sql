set ansi_nulls on
set quoted_identifier on
set nocount on
go

if not exists( select 1 from [dbo].[sysusers] where name=N'System.Activities.DurableInstancing.InstanceStoreUsers' and issqlrole=1 )
	create role [System.Activities.DurableInstancing.InstanceStoreUsers]
go

if not exists( select 1 from [dbo].[sysusers] where name=N'System.Activities.DurableInstancing.WorkflowActivationUsers' and issqlrole=1 )
	create role [System.Activities.DurableInstancing.WorkflowActivationUsers]
go

if not exists( select 1 from [dbo].[sysusers] where name=N'System.Activities.DurableInstancing.InstanceStoreObservers' and issqlrole=1 )
	create role [System.Activities.DurableInstancing.InstanceStoreObservers]
go

if not exists (select * from sys.schemas where name = N'System.Activities.DurableInstancing')
	exec ('create schema [System.Activities.DurableInstancing]')
go

if exists (select * from sys.views where object_id = object_id(N'[System.Activities.DurableInstancing].[InstancePromotedProperties]'))
      drop view [System.Activities.DurableInstancing].[InstancePromotedProperties]
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[InstancesTable]') and type in (N'U'))
	drop table [System.Activities.DurableInstancing].[InstancesTable]
go

create table [System.Activities.DurableInstancing].[InstancesTable]
(
	[Id] uniqueidentifier not null,
	[SurrogateInstanceId] bigint identity not null,
	[SurrogateLockOwnerId] bigint null,
	[PrimitiveDataProperties] varbinary(max) default null,
	[ComplexDataProperties] varbinary(max) default null,
	[WriteOnlyPrimitiveDataProperties] varbinary(max) default null,
	[WriteOnlyComplexDataProperties] varbinary(max) default null,
	[MetadataProperties] varbinary(max) default null,
	[DataEncodingOption] tinyint default 0,
	[MetadataEncodingOption] tinyint default 0,
	[Version] bigint not null,
	[PendingTimer] datetime null,
	[CreationTime] datetime not null,
	[LastUpdated] datetime default null,
	[WorkflowHostType] uniqueidentifier null,
	[ServiceDeploymentId] bigint null,
	[SuspensionExceptionName] nvarchar(450) default null,
	[SuspensionReason] nvarchar(max) default null,
	[BlockingBookmarks] nvarchar(max) default null,
	[LastMachineRunOn] nvarchar(450) default null,
	[ExecutionStatus] nvarchar(450) default null,
	[IsInitialized] bit default 0,
	[IsSuspended] bit default 0,
	[IsReadyToRun] bit default 0,
	[IsCompleted] bit default 0,
	[SurrogateIdentityId] bigint not null
)
go

--SQL Azure doesn't support allow_page_lock option. A conditional compilation is done to remove allow_page_lock in SQL Azure.
if (serverproperty('EngineEdition') = 5)
begin
	alter table [System.Activities.DurableInstancing].[InstancesTable]
		ADD CONSTRAINT CIX_InstancesTable
		  PRIMARY KEY CLUSTERED (SurrogateInstanceId)
end
else
begin
	alter table [System.Activities.DurableInstancing].[InstancesTable]
		ADD CONSTRAINT CIX_InstancesTable
		  PRIMARY KEY CLUSTERED (SurrogateInstanceId)
		  with (allow_page_locks = off)
end
go

if (serverproperty('EngineEdition') = 5)
begin
	exec('
		create unique nonclustered index [NCIX_InstancesTable_Id]
			on [System.Activities.DurableInstancing].[InstancesTable] ([Id])
			include ([Version], [SurrogateLockOwnerId], [IsCompleted])
	')
end
else
begin
	exec('
		create unique nonclustered index [NCIX_InstancesTable_Id]
			on [System.Activities.DurableInstancing].[InstancesTable] ([Id])
			include ([Version], [SurrogateLockOwnerId], [IsCompleted])
			with (allow_page_locks = off)
	')
end
go


if (serverproperty('EngineEdition') = 5)
begin
	exec('
		create nonclustered index [NCIX_InstancesTable_SurrogateLockOwnerId]
			on [System.Activities.DurableInstancing].[InstancesTable] ([SurrogateLockOwnerId])
	')
end
else
begin
	exec('
		create nonclustered index [NCIX_InstancesTable_SurrogateLockOwnerId]
			on [System.Activities.DurableInstancing].[InstancesTable] ([SurrogateLockOwnerId])
			with (allow_page_locks = off)
	')
end
go

if (serverproperty('EngineEdition') = 5)
begin
	exec('
		create nonclustered index NCIX_InstancesTable_LastUpdated
			on [System.Activities.DurableInstancing].[InstancesTable] ([LastUpdated])
	')
end
else
begin
	exec('
		create nonclustered index NCIX_InstancesTable_LastUpdated
			on [System.Activities.DurableInstancing].[InstancesTable] ([LastUpdated])
			with (allow_page_locks = off)
	')
end
go

if (serverproperty('EngineEdition') = 5)
begin
	exec('
		create nonclustered index [NCIX_InstancesTable_CreationTime]
			on [System.Activities.DurableInstancing].[InstancesTable] ([CreationTime])
	')
end
else
begin
	exec('
		create nonclustered index [NCIX_InstancesTable_CreationTime]
			on [System.Activities.DurableInstancing].[InstancesTable] ([CreationTime])
			with (allow_page_locks = off)
	')
end
go


if (serverproperty('EngineEdition') = 5)
begin
	exec('
		create nonclustered index [NCIX_InstancesTable_SuspensionExceptionName]
			on [System.Activities.DurableInstancing].[InstancesTable] ([SuspensionExceptionName])
	')
end
else
begin
	exec('
		create nonclustered index [NCIX_InstancesTable_SuspensionExceptionName]
			on [System.Activities.DurableInstancing].[InstancesTable] ([SuspensionExceptionName])
			with (allow_page_locks = off)
	')
end
go

if (serverproperty('EngineEdition') = 5)
begin
	exec('
		create nonclustered index [NCIX_InstancesTable_ServiceDeploymentId]
			on [System.Activities.DurableInstancing].[InstancesTable] ([ServiceDeploymentId])
	')
end
else
begin
	exec('
		create nonclustered index [NCIX_InstancesTable_ServiceDeploymentId]
			on [System.Activities.DurableInstancing].[InstancesTable] ([ServiceDeploymentId])
			with (allow_page_locks = off)
	')
end
go

if (serverproperty('EngineEdition') = 5)
begin
	exec('
		create nonclustered index [NCIX_InstancesTable_WorkflowHostType]
			on [System.Activities.DurableInstancing].[InstancesTable] ([WorkflowHostType])
	')
end
else
begin
	exec('
		create nonclustered index [NCIX_InstancesTable_WorkflowHostType]
			on [System.Activities.DurableInstancing].[InstancesTable] ([WorkflowHostType])
			with (allow_page_locks = off)
	')
end
go


if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[RunnableInstancesTable]') and type in (N'U'))
	drop table [System.Activities.DurableInstancing].[RunnableInstancesTable]
go

create table [System.Activities.DurableInstancing].[RunnableInstancesTable]
(
	[SurrogateInstanceId] bigint not null,		
	[WorkflowHostType] uniqueidentifier null,
	[ServiceDeploymentId] bigint null,
	[RunnableTime] datetime not null,
	[SurrogateIdentityId] bigint not null
)
go

--SQL Azure doesn't support allow_page_lock option. A conditional compilation is done to remove allow_page_lock in SQL Azure.
if (serverproperty('EngineEdition') = 5)
begin
	alter table [System.Activities.DurableInstancing].[RunnableInstancesTable]
		ADD CONSTRAINT CIX_RunnableInstancesTable_SurrogateInstanceId
			PRIMARY KEY CLUSTERED (SurrogateInstanceId)
			with (ignore_dup_key = on)
end
else
begin
	alter table [System.Activities.DurableInstancing].[RunnableInstancesTable]
		ADD CONSTRAINT CIX_RunnableInstancesTable_SurrogateInstanceId
			PRIMARY KEY CLUSTERED (SurrogateInstanceId)
			with (ignore_dup_key = on, allow_page_locks = off)
end
go

if (serverproperty('EngineEdition') = 5)
begin
	exec('
		create nonclustered index [NCIX_RunnableInstancesTable]
			on [System.Activities.DurableInstancing].[RunnableInstancesTable] ([WorkflowHostType], [RunnableTime])
	')
end
else
begin
	exec('
		create nonclustered index [NCIX_RunnableInstancesTable]
			on [System.Activities.DurableInstancing].[RunnableInstancesTable] ([WorkflowHostType], [RunnableTime])
			with (allow_page_locks = off)
	')
end
go

if (serverproperty('EngineEdition') = 5)
begin
	exec('
		create nonclustered index [NCIX_RunnableInstancesTable_RunnableTime]
			on [System.Activities.DurableInstancing].[RunnableInstancesTable] ([RunnableTime]) include ([WorkflowHostType], [ServiceDeploymentId])
	')
end
else
begin
	exec('
		create nonclustered index [NCIX_RunnableInstancesTable_RunnableTime]
			on [System.Activities.DurableInstancing].[RunnableInstancesTable] ([RunnableTime]) include ([WorkflowHostType], [ServiceDeploymentId])
			with (allow_page_locks = off)
	')
end
go

if (serverproperty('EngineEdition') = 5)
begin
	exec('
		create nonclustered index [NCIX_RunnableInstancesTable_SurrogateIdentityId]
			on [System.Activities.DurableInstancing].[RunnableInstancesTable] ([SurrogateIdentityId]) 
	')
end
else
begin
	exec('
		create nonclustered index [NCIX_RunnableInstancesTable_SurrogateIdentityId]
			on [System.Activities.DurableInstancing].[RunnableInstancesTable] ([SurrogateIdentityId]) 
			with (allow_page_locks = off)
	')
end
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[KeysTable]') and type in (N'U'))
	drop table [System.Activities.DurableInstancing].[KeysTable]
go

create table [System.Activities.DurableInstancing].[KeysTable]
(
	[Id] uniqueidentifier not null,
	[SurrogateKeyId] bigint identity not null,
	[SurrogateInstanceId] bigint null,
	[EncodingOption] tinyint null,
	[Properties] varbinary(max) null,
	[IsAssociated] bit
) 
go

--SQL Azure doesn't support allow_page_lock option. A conditional compilation is done to remove allow_page_lock in SQL Azure.
if (serverproperty('EngineEdition') = 5)
begin
	alter table [System.Activities.DurableInstancing].[KeysTable]
		ADD CONSTRAINT CIX_KeysTable
		  PRIMARY KEY CLUSTERED (Id)
		  with (ignore_dup_key = on)
end
else
begin
	alter table [System.Activities.DurableInstancing].[KeysTable]
		ADD CONSTRAINT CIX_KeysTable
		  PRIMARY KEY CLUSTERED (Id)
		  with (ignore_dup_key = on, allow_page_locks = off)
end
go

if (serverproperty('EngineEdition') = 5)
begin
	exec('
		create nonclustered index [NCIX_KeysTable_SurrogateInstanceId]
			on [System.Activities.DurableInstancing].[KeysTable] ([SurrogateInstanceId])
	')
end
else
begin
	exec('
		create nonclustered index [NCIX_KeysTable_SurrogateInstanceId]
			on [System.Activities.DurableInstancing].[KeysTable] ([SurrogateInstanceId])
			with (allow_page_locks = off)
	')
end
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[LockOwnersTable]') and type in (N'U'))
	drop table [System.Activities.DurableInstancing].[LockOwnersTable]
go

create table [System.Activities.DurableInstancing].[LockOwnersTable]
(
	[Id] uniqueidentifier not null,
	[SurrogateLockOwnerId] bigint identity not null,
	[LockExpiration] datetime not null,
	[WorkflowHostType] uniqueidentifier null,
	[MachineName] nvarchar(128) not null,
	[EnqueueCommand] bit not null,
	[DeletesInstanceOnCompletion] bit not null,
	[PrimitiveLockOwnerData] varbinary(max) default null,
	[ComplexLockOwnerData] varbinary(max) default null,
	[WriteOnlyPrimitiveLockOwnerData] varbinary(max) default null,
	[WriteOnlyComplexLockOwnerData] varbinary(max) default null,
	[EncodingOption] tinyint default 0,
	[WorkflowIdentityFilter] tinyint not null
)
go

--SQL Azure doesn't support allow_page_lock option. A conditional compilation is done to remove allow_page_lock in SQL Azure.
if (serverproperty('EngineEdition') = 5)
begin
	alter table [System.Activities.DurableInstancing].[LockOwnersTable]
		ADD CONSTRAINT CIX_LockOwnersTable
		  PRIMARY KEY CLUSTERED (SurrogateLockOwnerId)
end
else
begin
	alter table [System.Activities.DurableInstancing].[LockOwnersTable]
		ADD CONSTRAINT CIX_LockOwnersTable
		  PRIMARY KEY CLUSTERED (SurrogateLockOwnerId)
		  with (allow_page_locks = off)
end
go

if (serverproperty('EngineEdition') = 5)
begin
	exec('
		create unique nonclustered index [NCIX_LockOwnersTable_Id]
			on [System.Activities.DurableInstancing].[LockOwnersTable] ([Id])
			with (ignore_dup_key = on)
	')
end
else
begin
	exec('
		create unique nonclustered index [NCIX_LockOwnersTable_Id]
			on [System.Activities.DurableInstancing].[LockOwnersTable] ([Id])
			with (ignore_dup_key = on, allow_page_locks = off)
	')
end
go

if (serverproperty('EngineEdition') = 5)
begin
	exec('
		create nonclustered index [NCIX_LockOwnersTable_LockExpiration]
			on [System.Activities.DurableInstancing].[LockOwnersTable] ([LockExpiration]) include ([WorkflowHostType], [MachineName])
	')
end
else
begin
	exec('
		create nonclustered index [NCIX_LockOwnersTable_LockExpiration]
			on [System.Activities.DurableInstancing].[LockOwnersTable] ([LockExpiration]) include ([WorkflowHostType], [MachineName])
			with (allow_page_locks = off)
	')
end
go

if (serverproperty('EngineEdition') = 5)
begin
	exec('
		create nonclustered index [NCIX_LockOwnersTable_WorkflowHostType]
			on [System.Activities.DurableInstancing].[LockOwnersTable] ([WorkflowHostType])
	')
end
else
begin
	exec('
		create nonclustered index [NCIX_LockOwnersTable_WorkflowHostType]
			on [System.Activities.DurableInstancing].[LockOwnersTable] ([WorkflowHostType])
			with (allow_page_locks = off)
	')
end
go

if (serverproperty('EngineEdition') = 5)
begin
	exec('
		create nonclustered index [NCIX_LockOwnersTable_WorkflowIdentityFilter]
			on [System.Activities.DurableInstancing].[LockOwnersTable] ([WorkflowIdentityFilter])
	')
end
else
begin
	exec('
		create nonclustered index [NCIX_LockOwnersTable_WorkflowIdentityFilter]
			on [System.Activities.DurableInstancing].[LockOwnersTable] ([WorkflowIdentityFilter])
			with (allow_page_locks = off)
	')
end
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[InstanceMetadataChangesTable]') and type in (N'U'))
	drop table [System.Activities.DurableInstancing].[InstanceMetadataChangesTable]
go

create table [System.Activities.DurableInstancing].[InstanceMetadataChangesTable]
(
	[SurrogateInstanceId] bigint not null,
	[ChangeTime] bigint identity not null,
	[EncodingOption] tinyint not null,
	[Change] varbinary(max) not null
)
go

alter table [System.Activities.DurableInstancing].[InstanceMetadataChangesTable]
	ADD CONSTRAINT CIX_InstanceMetadataChangesTable
		PRIMARY KEY CLUSTERED (SurrogateInstanceId, ChangeTime)
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[ServiceDeploymentsTable]') and type in (N'U'))
	drop table [System.Activities.DurableInstancing].[ServiceDeploymentsTable]
go

create table [System.Activities.DurableInstancing].[ServiceDeploymentsTable]
(
	[Id] bigint identity not null,
	[ServiceDeploymentHash] uniqueidentifier not null,
	[SiteName] nvarchar(max) not null,
	[RelativeServicePath] nvarchar(max) not null,
	[RelativeApplicationPath] nvarchar(max) not null,
	[ServiceName] nvarchar(max) not null,
	[ServiceNamespace] nvarchar(max) not null,
)
go

--SQL Azure doesn't support allow_page_lock option. A conditional compilation is done to remove allow_page_lock in SQL Azure.
if (serverproperty('EngineEdition') = 5)
begin
	alter table [System.Activities.DurableInstancing].[ServiceDeploymentsTable]
		ADD CONSTRAINT CIX_ServiceDeploymentsTable
		  PRIMARY KEY CLUSTERED (Id)
end
else
begin
	alter table [System.Activities.DurableInstancing].[ServiceDeploymentsTable]
		ADD CONSTRAINT CIX_ServiceDeploymentsTable
		  PRIMARY KEY CLUSTERED (Id)
		  with (allow_page_locks = off)
end
go

if (serverproperty('EngineEdition') = 5)
begin
	exec('
		create unique nonclustered index [NCIX_ServiceDeploymentsTable_ServiceDeploymentHash]
			on [System.Activities.DurableInstancing].[ServiceDeploymentsTable] ([ServiceDeploymentHash])
			with (ignore_dup_key = on)
	')
end
else
begin
	exec('
		create unique nonclustered index [NCIX_ServiceDeploymentsTable_ServiceDeploymentHash]
			on [System.Activities.DurableInstancing].[ServiceDeploymentsTable] ([ServiceDeploymentHash])
			with (ignore_dup_key = on, allow_page_locks = off)
	')
end
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[InstancePromotedPropertiesTable]') and type in (N'U'))
	drop table [System.Activities.DurableInstancing].[InstancePromotedPropertiesTable]
go

create table [System.Activities.DurableInstancing].[InstancePromotedPropertiesTable]
(
	  [SurrogateInstanceId] bigint not null,
      [PromotionName] nvarchar(400) not null,
      [Value1] sql_variant null,
      [Value2] sql_variant null,
      [Value3] sql_variant null,
      [Value4] sql_variant null,
      [Value5] sql_variant null,
      [Value6] sql_variant null,
      [Value7] sql_variant null,
      [Value8] sql_variant null,
      [Value9] sql_variant null,
      [Value10] sql_variant null,
      [Value11] sql_variant null,
      [Value12] sql_variant null,
      [Value13] sql_variant null,
      [Value14] sql_variant null,
      [Value15] sql_variant null,
      [Value16] sql_variant null,
      [Value17] sql_variant null,
      [Value18] sql_variant null,
      [Value19] sql_variant null,
      [Value20] sql_variant null,
      [Value21] sql_variant null,
      [Value22] sql_variant null,
      [Value23] sql_variant null,
      [Value24] sql_variant null,
      [Value25] sql_variant null,
      [Value26] sql_variant null,
      [Value27] sql_variant null,
      [Value28] sql_variant null,
      [Value29] sql_variant null,
      [Value30] sql_variant null,
      [Value31] sql_variant null,
      [Value32] sql_variant null,
      [Value33] varbinary(max) null,
      [Value34] varbinary(max) null,
      [Value35] varbinary(max) null,
      [Value36] varbinary(max) null,
      [Value37] varbinary(max) null,
      [Value38] varbinary(max) null,
      [Value39] varbinary(max) null,
      [Value40] varbinary(max) null,
      [Value41] varbinary(max) null,
      [Value42] varbinary(max) null,
      [Value43] varbinary(max) null,
      [Value44] varbinary(max) null,
      [Value45] varbinary(max) null,
      [Value46] varbinary(max) null,
      [Value47] varbinary(max) null,
      [Value48] varbinary(max) null,
      [Value49] varbinary(max) null,
      [Value50] varbinary(max) null,
      [Value51] varbinary(max) null,
      [Value52] varbinary(max) null,
      [Value53] varbinary(max) null,
      [Value54] varbinary(max) null,
      [Value55] varbinary(max) null,
      [Value56] varbinary(max) null,
      [Value57] varbinary(max) null,
      [Value58] varbinary(max) null,
      [Value59] varbinary(max) null,
      [Value60] varbinary(max) null,
      [Value61] varbinary(max) null,
      [Value62] varbinary(max) null,
      [Value63] varbinary(max) null,
      [Value64] varbinary(max) null
)
go

--SQL Azure doesn't support allow_page_lock option. A conditional compilation is done to remove allow_page_lock in SQL Azure.
if (serverproperty('EngineEdition') = 5)
begin
	alter table [System.Activities.DurableInstancing].[InstancePromotedPropertiesTable]
		ADD CONSTRAINT CIX_InstancePromotedPropertiesTable
		  PRIMARY KEY CLUSTERED (SurrogateInstanceId, PromotionName)
end
else
begin
	alter table [System.Activities.DurableInstancing].[InstancePromotedPropertiesTable]
		ADD CONSTRAINT CIX_InstancePromotedPropertiesTable
		  PRIMARY KEY CLUSTERED (SurrogateInstanceId, PromotionName)
		  with (allow_page_locks = off)
end
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[SqlWorkflowInstanceStoreVersionTable]') and type in (N'U'))
	drop table [System.Activities.DurableInstancing].[SqlWorkflowInstanceStoreVersionTable]
go

create table [System.Activities.DurableInstancing].[SqlWorkflowInstanceStoreVersionTable]
(
	[Major] bigint NOT NULL,
	[Minor] bigint NOT NULL,
	[Build] bigint NOT NULL,
	[Revision] bigint NOT NULL,
	[LastUpdated] datetime
)
go

alter table [System.Activities.DurableInstancing].[SqlWorkflowInstanceStoreVersionTable]
	ADD CONSTRAINT CIX_SqlWorkflowInstanceStoreVersionTable
		PRIMARY KEY CLUSTERED (Major, Minor, Build, Revision)
go

insert into [System.Activities.DurableInstancing].[SqlWorkflowInstanceStoreVersionTable]
values (4, 6, 0, 0, getutcdate())

if exists (select * from sys.views where object_id = object_id(N'[System.Activities.DurableInstancing].[ServiceDeployments]'))
      drop view [System.Activities.DurableInstancing].[ServiceDeployments]
go

create view [System.Activities.DurableInstancing].[ServiceDeployments] as
      select [Id] as [ServiceDeploymentId],
             [SiteName],
             [RelativeServicePath],
             [RelativeApplicationPath],
             [ServiceName],
             [ServiceNamespace]
      from [System.Activities.DurableInstancing].[ServiceDeploymentsTable]
go

grant select on object::[System.Activities.DurableInstancing].[ServiceDeployments] to [System.Activities.DurableInstancing.InstanceStoreObservers]
go

grant delete on object::[System.Activities.DurableInstancing].[ServiceDeployments] to [System.Activities.DurableInstancing.InstanceStoreUsers]
go

create view [System.Activities.DurableInstancing].[InstancePromotedProperties] with schemabinding as
      select [InstancesTable].[Id] as [InstanceId],
			 [InstancesTable].[DataEncodingOption] as [EncodingOption],
			 [PromotionName],
			 [Value1],
			 [Value2],
			 [Value3],
			 [Value4],
			 [Value5],
			 [Value6],
			 [Value7],
			 [Value8],
			 [Value9],
			 [Value10],
			 [Value11],
			 [Value12],
			 [Value13],
			 [Value14],
			 [Value15],
			 [Value16],
			 [Value17],
			 [Value18],
			 [Value19],
			 [Value20],
			 [Value21],
			 [Value22],
			 [Value23],
			 [Value24],
			 [Value25],
			 [Value26],
			 [Value27],
			 [Value28],
			 [Value29],
			 [Value30],
			 [Value31],
			 [Value32],
			 [Value33],
			 [Value34],
			 [Value35],
			 [Value36],
			 [Value37],
			 [Value38],
			 [Value39],
			 [Value40],
			 [Value41],
			 [Value42],
			 [Value43],
			 [Value44],
			 [Value45],
			 [Value46],
			 [Value47],
			 [Value48],
			 [Value49],
			 [Value50],
			 [Value51],
			 [Value52],
			 [Value53],
			 [Value54],
			 [Value55],
			 [Value56],
			 [Value57],
			 [Value58],
			 [Value59],
			 [Value60],
			 [Value61],
			 [Value62],
			 [Value63],
			 [Value64]
    from [System.Activities.DurableInstancing].[InstancePromotedPropertiesTable]
    join [System.Activities.DurableInstancing].[InstancesTable]
    on [InstancePromotedPropertiesTable].[SurrogateInstanceId] = [InstancesTable].[SurrogateInstanceId]
go

grant select on object::[System.Activities.DurableInstancing].[InstancePromotedProperties] to [System.Activities.DurableInstancing.InstanceStoreObservers]
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[DefinitionIdentityTable]') and type in (N'U'))
	drop table [System.Activities.DurableInstancing].[DefinitionIdentityTable]
go

create table [System.Activities.DurableInstancing].[DefinitionIdentityTable]
(
	[SurrogateIdentityId] bigint identity not null,
	[DefinitionIdentityHash] uniqueidentifier not null,
	[DefinitionIdentityAnyRevisionHash] uniqueidentifier not null,
	[Name] nvarchar(max) null,
	[Package] nvarchar(max) null,
	[Build] bigint null,
	[Major] bigint null,
	[Minor] bigint null,
	[Revision] bigint null
)
go

--SQL Azure doesn't support allow_page_lock option. A conditional compilation is done to remove allow_page_lock in SQL Azure.
if (serverproperty('EngineEdition') = 5)
begin
	alter table [System.Activities.DurableInstancing].[DefinitionIdentityTable]
		ADD CONSTRAINT CIX_DefinitionIdentityTable
			PRIMARY KEY CLUSTERED (SurrogateIdentityId)
end
else
begin
	alter table [System.Activities.DurableInstancing].[DefinitionIdentityTable]
		ADD CONSTRAINT CIX_DefinitionIdentityTable
			PRIMARY KEY CLUSTERED (SurrogateIdentityId)
			with (allow_page_locks = off)
end
go

if (serverproperty('EngineEdition') = 5)
begin
	exec('
		create unique nonclustered index [NCIX_DefinitionIdentityTable_DefinitionIdentityHash]
			on [System.Activities.DurableInstancing].[DefinitionIdentityTable] ([DefinitionIdentityHash])
			with (ignore_dup_key = on)
	')
end
else
begin
	exec('
		create unique nonclustered index [NCIX_DefinitionIdentityTable_DefinitionIdentityHash]
			on [System.Activities.DurableInstancing].[DefinitionIdentityTable] ([DefinitionIdentityHash])
			with (ignore_dup_key = on, allow_page_locks = off)
	')
end
go

if (serverproperty('EngineEdition') = 5)
begin
	exec('
		create nonclustered index [NCIX_DefinitionIdentityTable_DefinitionIdentityAnyRevisionHash]
			on [System.Activities.DurableInstancing].[DefinitionIdentityTable] ([DefinitionIdentityAnyRevisionHash])
	')
end
else
begin
	exec('
		create nonclustered index [NCIX_DefinitionIdentityTable_DefinitionIdentityAnyRevisionHash]
			on [System.Activities.DurableInstancing].[DefinitionIdentityTable] ([DefinitionIdentityAnyRevisionHash])
			with (allow_page_locks = off)
	')
end
go

insert into [System.Activities.DurableInstancing].[DefinitionIdentityTable]
(
	[DefinitionIdentityHash],
	[DefinitionIdentityAnyRevisionHash],
	[Name],
	[Package],
	[Build],
	[Major],
	[Minor],
	[Revision]
)
values
(
	'00000000-0000-0000-0000-000000000000',
	'00000000-0000-0000-0000-000000000000',
	null,
	null,
	null,
	null,
	null,
	null
)
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[IdentityOwnerTable]') and type in (N'U'))
	drop table [System.Activities.DurableInstancing].[IdentityOwnerTable]
go

create table [System.Activities.DurableInstancing].[IdentityOwnerTable]
(
	[SurrogateIdentityId] bigint not null,
	[SurrogateLockOwnerId] bigint not null
)
go

if (serverproperty('EngineEdition') = 5)
begin
	alter table [System.Activities.DurableInstancing].[IdentityOwnerTable]
		ADD CONSTRAINT NCIX_IdentityOwnerTable_IdentityOwner
			PRIMARY KEY CLUSTERED (SurrogateLockOwnerId, SurrogateIdentityId)
end
else
begin
	alter table [System.Activities.DurableInstancing].[IdentityOwnerTable]
		ADD CONSTRAINT NCIX_IdentityOwnerTable_IdentityOwner
			PRIMARY KEY CLUSTERED (SurrogateLockOwnerId, SurrogateIdentityId)
			with (allow_page_locks = off)
end
go


if exists (select * from sys.views where object_id = object_id(N'[System.Activities.DurableInstancing].[Instances]'))
      drop view [System.Activities.DurableInstancing].[Instances]
go

create view [System.Activities.DurableInstancing].[Instances] as
      select [InstancesTable].[Id] as [InstanceId],
             [PendingTimer],
             [CreationTime],
             [LastUpdated] as [LastUpdatedTime],
             [InstancesTable].[ServiceDeploymentId],
             [SuspensionExceptionName],
             [SuspensionReason],
             [BlockingBookmarks] as [ActiveBookmarks],
             case when [LockOwnersTable].[LockExpiration] > getutcdate()
				then [LockOwnersTable].[MachineName]
				else null
				end as [CurrentMachine],
             [LastMachineRunOn] as [LastMachine],
             [ExecutionStatus],
             [IsInitialized],
             [IsSuspended],
             [IsCompleted],
             [InstancesTable].[DataEncodingOption] as [EncodingOption],
             [PrimitiveDataProperties] as [ReadWritePrimitiveDataProperties],
             [WriteOnlyPrimitiveDataProperties],
             [ComplexDataProperties] as [ReadWriteComplexDataProperties],
             [WriteOnlyComplexDataProperties],
             [Name] as [IdentityName],
             [Package] as [IdentityPackage],
             [Build],
             [Major],
             [Minor],
             [Revision]
      from [System.Activities.DurableInstancing].[InstancesTable]
      left outer join [System.Activities.DurableInstancing].[LockOwnersTable]
      on [InstancesTable].[SurrogateLockOwnerId] = [LockOwnersTable].[SurrogateLockOwnerId]
      join [System.Activities.DurableInstancing].[DefinitionIdentityTable]
      on [InstancesTable].[SurrogateIdentityId] = [DefinitionIdentityTable].[SurrogateIdentityId]
go

grant select on object::[System.Activities.DurableInstancing].[Instances] to [System.Activities.DurableInstancing.InstanceStoreObservers]
go

grant delete on object::[System.Activities.DurableInstancing].[Instances] to [System.Activities.DurableInstancing.InstanceStoreUsers]
go
