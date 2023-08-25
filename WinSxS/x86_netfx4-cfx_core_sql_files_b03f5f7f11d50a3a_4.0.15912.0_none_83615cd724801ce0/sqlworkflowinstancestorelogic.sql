set ansi_nulls on
set quoted_identifier on
set nocount on
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[InsertRunnableInstanceEntry]') and type in (N'P', N'PC'))
	drop procedure [System.Activities.DurableInstancing].[InsertRunnableInstanceEntry]
go

create procedure [System.Activities.DurableInstancing].[InsertRunnableInstanceEntry]
	@surrogateInstanceId bigint,
	@workflowHostType uniqueidentifier,
	@serviceDeploymentId bigint, 
	@isSuspended bit,
	@isReadyToRun bit,
	@pendingTimer datetime,
	@surrogateIdentityId bigint
AS
begin    
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;	
	
	declare @runnableTime datetime
	
	if (@isSuspended  = 0)
	begin
		if (@isReadyToRun = 1)
		begin
			set @runnableTime = getutcdate()					
		end
		else if (@pendingTimer is not null)
		begin
			set @runnableTime = @pendingTimer
		end
	end
		
	if (@runnableTime is not null and @workflowHostType is not null)
	begin	
		insert into [RunnableInstancesTable]
			([SurrogateInstanceId], [WorkflowHostType], [ServiceDeploymentId], [RunnableTime], [SurrogateIdentityId])
			values( @surrogateInstanceId, @workflowHostType, @serviceDeploymentId, @runnableTime, @surrogateIdentityId)
	end
end
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[RecoverInstanceLocks]') and type in (N'P', N'PC'))
	drop procedure [System.Activities.DurableInstancing].[RecoverInstanceLocks]
go

create procedure [System.Activities.DurableInstancing].[RecoverInstanceLocks]
as
begin
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;
	set deadlock_priority low;
    
	declare @now as datetime
	set @now = getutcdate()	
	
	insert into [RunnableInstancesTable] ([SurrogateInstanceId], [WorkflowHostType], [ServiceDeploymentId], [RunnableTime], [SurrogateIdentityId])
		select top (1000) instances.[SurrogateInstanceId], instances.[WorkflowHostType], instances.[ServiceDeploymentId], @now, instances.[SurrogateIdentityId]
		from [LockOwnersTable] lockOwners with (readpast) inner loop join
			 [InstancesTable] instances with (readpast)
				on instances.[SurrogateLockOwnerId] = lockOwners.[SurrogateLockOwnerId]
			where 
				lockOwners.[LockExpiration] <= @now and
				instances.[IsInitialized] = 1 and
				instances.[IsSuspended] = 0
	
	delete from [IdentityOwnerTable] with (readpast)
	where [IdentityOwnerTable].[SurrogateLockOwnerId] in
	(
		select [SurrogateLockOwnerId]
		from [System.Activities.DurableInstancing].[LockOwnersTable] lockOwners
		where [LockExpiration] <= @now
		and not exists
		(
			select top (1) 1
			from [System.Activities.DurableInstancing].[InstancesTable] instances with (nolock)
			where instances.[SurrogateLockOwnerId] = lockOwners.[SurrogateLockOwnerId]
		)
	)

	delete from [LockOwnersTable] with (readpast)
	from [LockOwnersTable] lockOwners
	where [LockExpiration] <= @now
	and not exists
	(
		select top (1) 1
		from [InstancesTable] instances with (nolock)
		where instances.[SurrogateLockOwnerId] = lockOwners.[SurrogateLockOwnerId]
	)
end
go

grant execute on [System.Activities.DurableInstancing].[RecoverInstanceLocks] to [System.Activities.DurableInstancing.InstanceStoreUsers]
go

grant execute on [System.Activities.DurableInstancing].[RecoverInstanceLocks] to [System.Activities.DurableInstancing.WorkflowActivationUsers]
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[ParseBinaryPropertyValue]') and type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	drop function [System.Activities.DurableInstancing].[ParseBinaryPropertyValue]
go

create function [System.Activities.DurableInstancing].[ParseBinaryPropertyValue] (@startPosition int, @length int, @concatenatedKeyProperties varbinary(max))
returns varbinary(max)
as
begin
	if (@length > 0)
		return substring(@concatenatedKeyProperties, @startPosition + 1, @length)
	return null
end
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[GetExpirationTime]') and type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	drop function [System.Activities.DurableInstancing].[GetExpirationTime]
go

create function [System.Activities.DurableInstancing].[GetExpirationTime] (@offsetInMilliseconds bigint)
returns datetime
as
begin

	if (@offsetInMilliseconds is null)
	begin
		return null
	end

	declare @hourInMillisecond bigint
	declare @offsetInHours bigint
	declare @remainingOffsetInMilliseconds bigint
	declare @expirationTimer datetime

	set @hourInMillisecond = 60*60*1000
	set @offsetInHours = @offsetInMilliseconds / @hourInMillisecond
	set @remainingOffsetInMilliseconds = @offsetInMilliseconds % @hourInMillisecond

	set @expirationTimer = getutcdate()
	set @expirationTimer = dateadd (hour, @offsetInHours, @expirationTimer)
	set @expirationTimer = dateadd (millisecond,@remainingOffsetInMilliseconds, @expirationTimer)

	return @expirationTimer

end
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[InsertDefinitionIdentity]') and type in (N'P', N'PC'))
	drop procedure [System.Activities.DurableInstancing].[InsertDefinitionIdentity]
go
create procedure [System.Activities.DurableInstancing].[InsertDefinitionIdentity]	
	@identityMetadata xml = null
as
begin
	set nocount on
	set transaction isolation level read committed		
	set xact_abort on;
	
	if (@identityMetadata is not null)
	 begin
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
		select 	T.Item.value('DefinitionIdentityHash[1]', 'uniqueidentifier'),
				T.Item.value('DefinitionIdentityAnyRevisionHash[1]', 'uniqueidentifier'),
				T.Item.value('Name[1]', 'nvarchar(max)'),
				T.Item.value('Package[1]', 'nvarchar(max)'),
				T.Item.value('Build[1]', 'bigint'),
				T.Item.value('Major[1]', 'bigint'),
				T.Item.value('Minor[1]', 'bigint'),
				T.Item.value('Revision[1]', 'bigint')
		from	@identityMetadata.nodes('/IdentityMetadata/IdentityCollection/Identity') as T(Item)
	 end	
end	
go

grant execute on [System.Activities.DurableInstancing].[InsertDefinitionIdentity] to [System.Activities.DurableInstancing.InstanceStoreUsers] 
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[CreateLockOwner]') and type in (N'P', N'PC'))
	drop procedure [System.Activities.DurableInstancing].[CreateLockOwner]
go

create procedure [System.Activities.DurableInstancing].[CreateLockOwner]
	@lockOwnerId uniqueidentifier,
	@lockTimeout int,
	@workflowHostType uniqueidentifier,
	@enqueueCommand bit,
	@deleteInstanceOnCompletion bit,	
	@primitiveLockOwnerData varbinary(max),
	@complexLockOwnerData varbinary(max),
	@writeOnlyPrimitiveLockOwnerData varbinary(max),
	@writeOnlyComplexLockOwnerData varbinary(max),
	@encodingOption tinyint,
	@machineName nvarchar(128),
	@identityMetadata xml = null
as
begin
	set nocount on
	set transaction isolation level read committed
	set xact_abort on;	
	
	begin transaction
	
	declare @lockAcquired bigint
	declare @lockExpiration datetime
	declare @now datetime
	declare @result int
	declare @surrogateLockOwnerId bigint
	declare @workflowIdentityFilter tinyint

	set @result = 0
	
	exec @lockAcquired = sp_getapplock @Resource = 'InstanceStoreLock', @LockMode = 'Shared', @LockTimeout = 10000
		
	if (@lockAcquired < 0)
	begin
		select @result as 'Result'
		set @result = 13
	end
	
	if (@result = 0)
	begin
		-- insert the list of identity to the DefinitionIdentityTable
		exec [System.Activities.DurableInstancing].[InsertDefinitionIdentity] @identityMetadata
		
		if (@identityMetadata is not null)
		 begin
			select @workflowIdentityFilter = T.Item.value('WorkflowIdentityFilter[1]', 'tinyint')
			from @identityMetadata.nodes('/IdentityMetadata') as T(Item)
		 end
		
		if @workflowIdentityFilter is null
			set @workflowIdentityFilter = 0

		--Create Lock Owner entry 
		set @now = getutcdate()
		
		if (@lockTimeout = 0)
			set @lockExpiration = '9999-12-31T23:59:59';
		else 
			set @lockExpiration = dateadd(second, @lockTimeout, getutcdate());
		
		insert into [LockOwnersTable] ([Id], [LockExpiration], [MachineName], [WorkflowHostType], [EnqueueCommand], [DeletesInstanceOnCompletion], [PrimitiveLockOwnerData], [ComplexLockOwnerData], [WriteOnlyPrimitiveLockOwnerData], [WriteOnlyComplexLockOwnerData], [EncodingOption], [WorkflowIdentityFilter])
		values (@lockOwnerId, @lockExpiration, @machineName, @workflowHostType, @enqueueCommand, @deleteInstanceOnCompletion, @primitiveLockOwnerData, @complexLockOwnerData, @writeOnlyPrimitiveLockOwnerData, @writeOnlyComplexLockOwnerData, @encodingOption, @workflowIdentityFilter)
		
		set @surrogateLockOwnerId = scope_identity()
		
		-- insert identity collection with its lock owner.
		if (@identityMetadata is not null)
		 begin
			insert into [System.Activities.DurableInstancing].[IdentityOwnerTable] 
			(
						[SurrogateIdentityId], 
						[SurrogateLockOwnerId]
			)
			select		[System.Activities.DurableInstancing].[DefinitionIdentityTable].[SurrogateIdentityId], 
						@surrogateLockOwnerId
			from		[System.Activities.DurableInstancing].[DefinitionIdentityTable]
			where		[System.Activities.DurableInstancing].[DefinitionIdentityTable].[DefinitionIdentityHash] in
						(
							select	T.Item.value('DefinitionIdentityHash[1]', 'uniqueidentifier') 
							from	@identityMetadata.nodes('/IdentityMetadata/IdentityCollection/Identity') as T(Item)
						)
		 end
		else
		 begin
			insert into [System.Activities.DurableInstancing].[IdentityOwnerTable] 
			(
				[SurrogateIdentityId], 
				[SurrogateLockOwnerId]
			)
			select  [SurrogateIdentityId], @surrogateLockOwnerId
			from	[System.Activities.DurableInstancing].[DefinitionIdentityTable]
			where	[DefinitionIdentityHash] = '00000000-0000-0000-0000-000000000000'
		 end 
	end
	
	if (@result != 13)
		exec sp_releaseapplock @Resource = 'InstanceStoreLock'
	
	if (@result = 0)
	begin
		commit transaction
		select 0 as 'Result', @surrogateLockOwnerId
	end
	else
		rollback transaction
end
go

grant execute on [System.Activities.DurableInstancing].[CreateLockOwner] to [System.Activities.DurableInstancing.InstanceStoreUsers] 
go

grant execute on [System.Activities.DurableInstancing].[CreateLockOwner] to [System.Activities.DurableInstancing.WorkflowActivationUsers] 
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[DeleteLockOwner]') and type in (N'P', N'PC'))
	drop procedure [System.Activities.DurableInstancing].[DeleteLockOwner]
go

create procedure [System.Activities.DurableInstancing].[DeleteLockOwner]
	@surrogateLockOwnerId bigint
as
begin
	set nocount on
	set transaction isolation level read committed
	set deadlock_priority low
	set xact_abort on;	
	
	begin transaction
	
	declare @lockAcquired bigint
	declare @result int
	set @result = 0
	
	exec @lockAcquired = sp_getapplock @Resource = 'InstanceStoreLock', @LockMode = 'Shared', @LockTimeout = 10000
		
	if (@lockAcquired < 0)
	begin
		select @result as 'Result'
		set @result = 13
	end
	
	if (@result = 0)
	begin
		update [LockOwnersTable]
		set [LockExpiration] = '2000-01-01T00:00:00'
		where [SurrogateLockOwnerId] = @surrogateLockOwnerId
	end
	
	if (@result != 13)
		exec sp_releaseapplock @Resource = 'InstanceStoreLock' 
	
	if (@result = 0)
	begin
		commit transaction
		select 0 as 'Result'
	end
	else
		rollback transaction
end
go

grant execute on [System.Activities.DurableInstancing].[DeleteLockOwner] to [System.Activities.DurableInstancing.InstanceStoreUsers] 
go

grant execute on [System.Activities.DurableInstancing].[DeleteLockOwner] to [System.Activities.DurableInstancing.WorkflowActivationUsers] 
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[ExtendLock]') and type in (N'P', N'PC'))
	drop procedure [System.Activities.DurableInstancing].[ExtendLock]
go
create procedure [System.Activities.DurableInstancing].[ExtendLock]
	@surrogateLockOwnerId bigint,
	@lockTimeout int	
as
begin
	set nocount on
	set transaction isolation level read committed
	set xact_abort on;	
	
	begin transaction	
	
	declare @now datetime
	declare @newLockExpiration datetime
	declare @result int
	
	set @now = getutcdate()
	set @result = 0
	
	if (@lockTimeout = 0)
		set @newLockExpiration = '9999-12-31T23:59:59'
	else
		set @newLockExpiration = dateadd(second, @lockTimeout, @now)
	
	update [LockOwnersTable]
	set [LockExpiration] = @newLockExpiration
	where ([SurrogateLockOwnerId] = @surrogateLockOwnerId) and
		  ([LockExpiration] > @now)
	
	if (@@rowcount = 0) 
	begin
		if exists (select * from [LockOwnersTable] where ([SurrogateLockOwnerId] = @surrogateLockOwnerId))
		begin
			exec [System.Activities.DurableInstancing].[DeleteLockOwner] @surrogateLockOwnerId
			set @result = 11
		end
		else
			set @result = 12
	end
	
	select @result as 'Result'
	commit transaction
end
go

grant execute on [System.Activities.DurableInstancing].[ExtendLock] to [System.Activities.DurableInstancing.InstanceStoreUsers] 
go

grant execute on [System.Activities.DurableInstancing].[ExtendLock] to [System.Activities.DurableInstancing.WorkflowActivationUsers] 
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[AssociateKeys]') and type in (N'P', N'PC'))
	drop procedure [System.Activities.DurableInstancing].[AssociateKeys]
go
create procedure [System.Activities.DurableInstancing].[AssociateKeys]
	@surrogateInstanceId bigint,
	@keysToAssociate xml = null,
	@concatenatedKeyProperties varbinary(max) = null,
	@encodingOption tinyint,
	@singleKeyId uniqueidentifier
as
begin	
	set nocount on
	set transaction isolation level read committed
	set xact_abort on;	
	
	declare @badKeyId uniqueidentifier
	declare @numberOfKeys int
	declare @result int
	declare @keys table([KeyId] uniqueidentifier, [Properties] varbinary(max))
	
	set @result = 0
	
	if (@keysToAssociate is not null)
	begin
		insert into @keys
		select T.Item.value('@KeyId', 'uniqueidentifier') as [KeyId],
			   [System.Activities.DurableInstancing].[ParseBinaryPropertyValue](T.Item.value('@StartPosition', 'int'), T.Item.value('@BinaryLength', 'int'), @concatenatedKeyProperties) as [Properties]
	    from @keysToAssociate.nodes('/CorrelationKeys/CorrelationKey') as T(Item)
		option (maxdop 1)

		select @numberOfKeys = count(1) from @keys
		
		insert into [KeysTable] ([Id], [SurrogateInstanceId], [IsAssociated])
		select [KeyId], @surrogateInstanceId, 1
		from @keys as [Keys]
		
		if (@@rowcount != @numberOfKeys)
		begin
			select top 1 @badKeyId = [Keys].[KeyId] 
			from @keys as [Keys]
			join [KeysTable] on [Keys].[KeyId] = [KeysTable].[Id]
			where [KeysTable].[SurrogateInstanceId] != @surrogateInstanceId
			
			if (@@rowcount != 0)
			begin
				select 3 as 'Result', @badKeyId
				return 3
			end
		end
		
		update [KeysTable]
		set [Properties] = [Keys].[Properties],
			[EncodingOption] = @encodingOption
		from @keys as [Keys]
		join [KeysTable] on [Keys].[KeyId] = [KeysTable].[Id]
		where [KeysTable].[EncodingOption] is null
	end
	
	if (@singleKeyId is not null)
	begin
InsertSingleKey:
		update [KeysTable]
		set [Properties] = @concatenatedKeyProperties,
			[EncodingOption] = @encodingOption
		where ([Id] = @singleKeyId) and ([SurrogateInstanceId] = @surrogateInstanceId)
			  
		if (@@rowcount != 1)
		begin
			if exists (select [Id] from [KeysTable] where [Id] = @singleKeyId)
			begin
				select 3 as 'Result', @singleKeyId
				return 3
			end
			
			insert into [KeysTable] ([Id], [SurrogateInstanceId], [IsAssociated], [Properties], [EncodingOption])
			values (@singleKeyId, @surrogateInstanceId, 1, @concatenatedKeyProperties, @encodingOption)
			
			if (@@rowcount = 0)
				goto InsertSingleKey
		end
	end
end
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[CompleteKeys]') and type in (N'P', N'PC'))
	drop procedure [System.Activities.DurableInstancing].[CompleteKeys]
go
create procedure [System.Activities.DurableInstancing].[CompleteKeys]
	@surrogateInstanceId bigint,
	@keysToComplete xml = null
as
begin	
	set nocount on
	set transaction isolation level read committed
	set xact_abort on;	
	
	declare @badKeyId uniqueidentifier
	declare @numberOfKeys int
	declare @result int
	declare @keyIds table([KeyId] uniqueidentifier)
	
	set @result = 0
	
	if (@keysToComplete is not null)
	begin
		insert into @keyIds
		select T.Item.value('@KeyId', 'uniqueidentifier')
		from @keysToComplete.nodes('//CorrelationKey') as T(Item)
		option(maxdop 1)
		
		select @numberOfKeys = count(1) from @keyIds
		
		update [KeysTable]
		set [IsAssociated] = 0
		from @keyIds as [KeyIds]
		join [KeysTable] on [KeyIds].[KeyId] = [KeysTable].[Id]
		where [SurrogateInstanceId] = @surrogateInstanceId
		
		if (@@rowcount != @numberOfKeys)
		begin
			select top 1 @badKeyId = [MissingKeys].[MissingKeyId]
			from
				(select [KeyIds].[KeyId] as [MissingKeyId] 
				 from @keyIds as [KeyIds]
				 except
				 select [Id] from [KeysTable] where [SurrogateInstanceId] = @surrogateInstanceId) as MissingKeys
		
			select 4 as 'Result', @badKeyId
			return 4
		end
	end
end
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[FreeKeys]') and type in (N'P', N'PC'))
	drop procedure [System.Activities.DurableInstancing].[FreeKeys]
go
create procedure [System.Activities.DurableInstancing].[FreeKeys]
	@surrogateInstanceId bigint,
	@keysToFree xml = null
as
begin	
	set nocount on
	set transaction isolation level read committed
	set xact_abort on;	
	
	declare @badKeyId uniqueidentifier
	declare @numberOfKeys int
	declare @result int
	declare @keyIds table([KeyId] uniqueidentifier)
	
	set @result = 0
	
	if (@keysToFree is not null)
	begin
		insert into @keyIds
		select T.Item.value('@KeyId', 'uniqueidentifier')
		from @keysToFree.nodes('//CorrelationKey') as T(Item)
		option(maxdop 1)
		
		select @numberOfKeys = count(1) from @keyIds
		
		delete [KeysTable]
		from @keyIds as [KeyIds]
		join [KeysTable] on [KeyIds].[KeyId] = [KeysTable].[Id]
		where [SurrogateInstanceId] = @surrogateInstanceId

		if (@@rowcount != @numberOfKeys)
		begin
			select top 1 @badKeyId = [MissingKeys].[MissingKeyId] from
				(select [KeyIds].[KeyId] as [MissingKeyId]
				 from @keyIds as [KeyIds]
				 except
				 select [Id] from [KeysTable] where [SurrogateInstanceId] = @surrogateInstanceId) as MissingKeys
		
			select 4 as 'Result', @badKeyId
			return 4
		end
	end
end
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[CreateInstance]') and type in (N'P', N'PC'))
	drop procedure [System.Activities.DurableInstancing].[CreateInstance]
go
create procedure [System.Activities.DurableInstancing].[CreateInstance]
	@instanceId uniqueidentifier,
	@surrogateLockOwnerId bigint,
	@workflowHostType uniqueidentifier,
	@serviceDeploymentId bigint,
	@surrogateInstanceId bigint output,
	@result int output
as
begin
	set nocount on
	set transaction isolation level read committed
	set xact_abort on;	
	
	set @surrogateInstanceId = 0
	set @result = 0
	declare	@surrogateIdentityId bigint
	
	select	@surrogateIdentityId = [SurrogateIdentityId]
	from	[System.Activities.DurableInstancing].[DefinitionIdentityTable]
	where	[DefinitionIdentityHash] = '00000000-0000-0000-0000-000000000000'
	and		[DefinitionIdentityAnyRevisionHash] = '00000000-0000-0000-0000-000000000000'
	and		[Name] is null
	and		[Package] is null
	and		[Build] is null
	and		[Major] is null
	and		[Minor] is null
	and		[Revision] is null

	if @surrogateIdentityId is null
	 begin
		goto Error
	 end
	else
	 begin
		begin try
			insert into [InstancesTable] ([Id], [SurrogateLockOwnerId], [CreationTime], [WorkflowHostType], [ServiceDeploymentId], [Version], [SurrogateIdentityId])
			values (@instanceId, @surrogateLockOwnerId, getutcdate(), @workflowHostType, @serviceDeploymentId, 1, @surrogateIdentityId)
			
			set @surrogateInstanceId = scope_identity()		
		end try
		begin catch
			if (error_number() != 2601)
			begin
				goto Error
			end
		end catch
	 end
	 
	 goto Done

Error:
	set @result = 99
	select @result as 'Result'
	
Done:

end
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[LockInstance]') and type in (N'P', N'PC'))
	drop procedure [System.Activities.DurableInstancing].[LockInstance]
go
create procedure [System.Activities.DurableInstancing].[LockInstance]
	@instanceId uniqueidentifier,
	@surrogateLockOwnerId bigint,
	@handleInstanceVersion bigint,
	@handleIsBoundToLock bit,
	@surrogateInstanceId bigint output,
	@lockVersion bigint output,
	@result int output
as
begin
	set nocount on
	set transaction isolation level read committed
	set xact_abort on;	
	
	declare @isCompleted bit
	declare @currentLockOwnerId bigint
	declare @currentVersion bigint

TryLockInstance:
	set @currentLockOwnerId = 0
	set @surrogateInstanceId = 0
	set @result = 0
	
	update [InstancesTable]
	set [SurrogateLockOwnerId] = @surrogateLockOwnerId,
		@lockVersion = [Version] = case when ([InstancesTable].[SurrogateLockOwnerId] is null or 
											  [InstancesTable].[SurrogateLockOwnerId] != @surrogateLockOwnerId)
									then [Version] + 1
									else [Version]
								  end,
		@surrogateInstanceId = [SurrogateInstanceId]
	from [InstancesTable]
	left outer join [LockOwnersTable] on [InstancesTable].[SurrogateLockOwnerId] = [LockOwnersTable].[SurrogateLockOwnerId]
	where ([InstancesTable].[Id] = @instanceId) and
		  ([InstancesTable].[IsCompleted] = 0) and
		  (
		   (@handleIsBoundToLock = 0 and
		    (
		     ([InstancesTable].[SurrogateLockOwnerId] is null) or
		     ([LockOwnersTable].[SurrogateLockOwnerId] is null) or
			  (
		       ([LockOwnersTable].[LockExpiration] < getutcdate()) and
               ([LockOwnersTable].[SurrogateLockOwnerId] != @surrogateLockOwnerId)
			  )
		    )
		   ) or 
		   (
			(@handleIsBoundToLock = 1) and
		    ([LockOwnersTable].[SurrogateLockOwnerId] = @surrogateLockOwnerId) and
		    ([LockOwnersTable].[LockExpiration] > getutcdate()) and
		    ([InstancesTable].[Version] = @handleInstanceVersion)
		   )
		  )
	
	if (@@rowcount = 0)
	begin
		if not exists (select * from [LockOwnersTable] where ([SurrogateLockOwnerId] = @surrogateLockOwnerId) and ([LockExpiration] > getutcdate()))
		begin
			if exists (select * from [LockOwnersTable] where [SurrogateLockOwnerId] = @surrogateLockOwnerId)
				set @result = 11
			else
				set @result = 12
			
			select @result as 'Result'
			return 0
		end
		
		select @currentLockOwnerId = [SurrogateLockOwnerId],
			   @isCompleted = [IsCompleted],
			   @currentVersion = [Version]
		from [InstancesTable]
		where [Id] = @instanceId
	
		if (@@rowcount = 1)
		begin
			if (@isCompleted = 1)
				set @result = 7
			else if (@currentLockOwnerId = @surrogateLockOwnerId)
			begin
				if (@handleIsBoundToLock = 1)
					set @result = 10
				else
					set @result = 14
			end
			else if (@handleIsBoundToLock = 0)
				set @result = 2
			else
				set @result = 6
		end
		else if (@handleIsBoundToLock = 1)
			set @result = 6
	end

	if (@result != 0 and @result != 2)
		select @result as 'Result', @instanceId, @currentVersion
	else if (@result = 2)
	begin
		select @result as 'Result', @instanceId, [LockOwnersTable].[Id], [LockOwnersTable].[EncodingOption], [PrimitiveLockOwnerData], [ComplexLockOwnerData]
		from [LockOwnersTable]
		join [InstancesTable] on [InstancesTable].[SurrogateLockOwnerId] = [LockOwnersTable].[SurrogateLockOwnerId]
		where [InstancesTable].[SurrogateLockOwnerId] = @currentLockOwnerId and
			  [InstancesTable].[Id] = @instanceId
		
		if (@@rowcount = 0)
			goto TryLockInstance
	end
end
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[UnlockInstance]') and type in (N'P', N'PC'))
	drop procedure [System.Activities.DurableInstancing].[UnlockInstance]
go
create procedure [System.Activities.DurableInstancing].[UnlockInstance]
	@surrogateLockOwnerId bigint,
	@instanceId uniqueidentifier,
	@handleInstanceVersion bigint
as
begin
	set nocount on
	set transaction isolation level read committed		
	set xact_abort on;	
	begin transaction
	
	declare @pendingTimer datetime
	declare @surrogateInstanceId bigint
	declare @workflowHostType uniqueidentifier
	declare @serviceDeploymentId bigint
	declare @enqueueCommand bit	
	declare @isReadyToRun bit	
	declare @isSuspended bit
	declare @now datetime
	declare @surrogateIdentityId bigint
	
	set @now = getutcdate()
		
	update [InstancesTable]
	set [SurrogateLockOwnerId] = null,
	    @surrogateInstanceId = [SurrogateInstanceId],
	    @workflowHostType = [WorkflowHostType],
   	    @serviceDeploymentId = [ServiceDeploymentId],
	    @pendingTimer = [PendingTimer],
	    @isReadyToRun =  [IsReadyToRun],
	    @isSuspended = [IsSuspended],
	    @surrogateIdentityId = [SurrogateIdentityId]
	where [Id] = @instanceId and
		  [SurrogateLockOwnerId] = @surrogateLockOwnerId and
		  [Version] = @handleInstanceVersion
	
	exec [System.Activities.DurableInstancing].[InsertRunnableInstanceEntry] @surrogateInstanceId, @workflowHostType, @serviceDeploymentId, @isSuspended, @isReadyToRun, @pendingTimer, @surrogateIdentityId    
	
	commit transaction
end
go

grant execute on [System.Activities.DurableInstancing].[UnlockInstance] to [System.Activities.DurableInstancing.InstanceStoreUsers] 
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[DetectRunnableInstances]') and type in (N'P', N'PC'))
	drop procedure [System.Activities.DurableInstancing].[DetectRunnableInstances]
go

create procedure [System.Activities.DurableInstancing].[DetectRunnableInstances]
	@workflowHostType uniqueidentifier,
	@surrogateLockOwnerId bigint = null
as
begin
	set nocount on
	set transaction isolation level read committed	
	set xact_abort on;	
	set deadlock_priority low
	
	declare @nextRunnableTime datetime
	declare @workflowIdentityFilter tinyint
	
	if (@surrogateLockOwnerId is not null)
	 begin
		select @workflowIdentityFilter = [WorkflowIdentityFilter]
		from [LockOwnersTable]
		where [LockOwnersTable].SurrogateLockOwnerId = @surrogateLockOwnerId
	 end
	
	if (@workflowIdentityFilter is null)
		set @workflowIdentityFilter = 0
				
	if (@workflowIdentityFilter = 1)
	begin
		-- Any Identity
		select top 1 @nextRunnableTime = [RunnableInstancesTable].[RunnableTime]
				  from [RunnableInstancesTable] with (readpast)
				  where [WorkflowHostType] = @workflowHostType
				  order by [WorkflowHostType], [RunnableTime]
	end
	else if (@workflowIdentityFilter = 2)
	begin
		--AnyRevision
		declare @AnyRevisionFilter table
		(
			DefinitionIdentityAnyRevisionHash uniqueidentifier
			UNIQUE (DefinitionIdentityAnyRevisionHash)
		)

		insert into @AnyRevisionFilter 
		select distinct [DefinitionIdentityAnyRevisionHash]
		from [DefinitionIdentityTable] as IdentityTable, [IdentityOwnerTable] as IdentityOwnerTable
		where IdentityOwnerTable.[SurrogateLockOwnerId] = @surrogateLockOwnerId 
			and 
			IdentityTable.[SurrogateIdentityId] = IdentityOwnerTable.[SurrogateIdentityId]
		
		select top 1 @nextRunnableTime = RunnableInstance.[RunnableTime]
				  from [RunnableInstancesTable] as RunnableInstance with (readpast) 
					inner loop join (
						select IdentityTable.[SurrogateIdentityId] as IdentityId
						from [System.Activities.DurableInstancing].[DefinitionIdentityTable] as IdentityTable, @AnyRevisionFilter as AnyRevision
						where IdentityTable.[DefinitionIdentityAnyRevisionHash] = AnyRevision.DefinitionIdentityAnyRevisionHash
					) as FilteredIdentities
					on RunnableInstance.[SurrogateIdentityId] =  FilteredIdentities.IdentityId
				  where RunnableInstance.[WorkflowHostType] = @workflowHostType
				  order by [WorkflowHostType], [RunnableTime]	
	end 
	else
		begin
			-- default to Exact
			if (@surrogateLockOwnerId is null)
			 begin
				declare	@surrogateIdentityId bigint
	
				select		@surrogateIdentityId = [SurrogateIdentityId]
				from		[System.Activities.DurableInstancing].[DefinitionIdentityTable]
				where		[DefinitionIdentityHash] = '00000000-0000-0000-0000-000000000000'
				and			[DefinitionIdentityAnyRevisionHash] = '00000000-0000-0000-0000-000000000000'
				and			[Name] is null
				and			[Package] is null
				and			[Build] is null
				and			[Major] is null
				and			[Minor] is null
				and			[Revision] is null
				
				select		top 1 @nextRunnableTime = RunnableInstances.[RunnableTime]
				from		[RunnableInstancesTable] as RunnableInstances with (readpast)
				where		[WorkflowHostType] = @workflowHostType
				and			[SurrogateIdentityId] = @surrogateIdentityId
				order by	[WorkflowHostType], [RunnableTime]	
			 end
			else
			 begin
				select top 1 @nextRunnableTime = RunnableInstances.[RunnableTime]
						  from [RunnableInstancesTable] as RunnableInstances with (readpast)
							inner loop join (
								select [SurrogateIdentityId] as IdentityId
								from [IdentityOwnerTable] 
								where [SurrogateLockOwnerId] = @surrogateLockOwnerId
							) as FilteredIdentities
							on RunnableInstances.[SurrogateIdentityId] = FilteredIdentities.IdentityId 
						  where [WorkflowHostType] = @workflowHostType
						  order by [WorkflowHostType], [RunnableTime]	
			 end
		end
	
	
	select 0 as 'Result', @nextRunnableTime, getutcdate()
end
go

grant execute on [System.Activities.DurableInstancing].[DetectRunnableInstances] to [System.Activities.DurableInstancing.InstanceStoreUsers] 
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[GetActivatableWorkflowsActivationParameters]') and type in (N'P', N'PC'))
	drop procedure [System.Activities.DurableInstancing].[GetActivatableWorkflowsActivationParameters]
go

create procedure [System.Activities.DurableInstancing].[GetActivatableWorkflowsActivationParameters]
	@machineName nvarchar(128)
as
begin
	set nocount on
	set transaction isolation level read committed	
	set xact_abort on;	
	set deadlock_priority low
	
	declare @now datetime
	set @now = getutcdate()
	
	select 0 as 'Result'
	
	select top(1000) serviceDeployments.[SiteName], serviceDeployments.[RelativeApplicationPath], serviceDeployments.[RelativeServicePath]
	from (
		select distinct [ServiceDeploymentId], [WorkflowHostType]
		from [RunnableInstancesTable] with (readpast)
		where [RunnableTime] <= @now
		) runnableWorkflows inner join [ServiceDeploymentsTable] serviceDeployments
		on runnableWorkflows.[ServiceDeploymentId] = serviceDeployments.[Id]
	where not exists (
						select top (1) 1
						from [LockOwnersTable] lockOwners
						where lockOwners.[LockExpiration] > @now
						and lockOwners.[MachineName] = @machineName
						and lockOwners.[WorkflowHostType] = runnableWorkflows.[WorkflowHostType]
					  )
end
go

grant execute on [System.Activities.DurableInstancing].[GetActivatableWorkflowsActivationParameters] to [System.Activities.DurableInstancing.InstanceStoreUsers]
go

grant execute on [System.Activities.DurableInstancing].[GetActivatableWorkflowsActivationParameters] to [System.Activities.DurableInstancing.WorkflowActivationUsers]
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[LoadInstance]') and type in (N'P', N'PC'))
	drop procedure [System.Activities.DurableInstancing].[LoadInstance]
go
create procedure [System.Activities.DurableInstancing].[LoadInstance]
	@surrogateLockOwnerId bigint,
	@operationType tinyint,
	@handleInstanceVersion bigint,
	@handleIsBoundToLock bit,
	@keyToLoadBy uniqueidentifier = null,
	@instanceId uniqueidentifier = null,
	@keysToAssociate xml = null,
	@encodingOption tinyint,
	@concatenatedKeyProperties varbinary(max) = null,
	@singleKeyId uniqueidentifier,
	@operationTimeout int
as
begin
	set nocount on
	set transaction isolation level read committed	
	set xact_abort on;		
	set deadlock_priority low
	begin transaction
	
	declare @result int
	declare @lockAcquired bigint
	declare @isInitialized bit
	declare @createKey bit
	declare @createdInstance bit
	declare @keyIsAssociated bit
	declare @loadedByKey bit
	declare @now datetime
	declare @surrogateInstanceId bigint

	set @createdInstance = 0
	set @isInitialized = 0
	set @keyIsAssociated = 0
	set @result = 0
	set @surrogateInstanceId = null
	
	exec @lockAcquired = sp_getapplock @Resource = 'InstanceStoreLock', @LockMode = 'Shared', @LockTimeout = @operationTimeout
	
	if (@lockAcquired < 0)
	begin
		set @result = 13
		select @result as 'Result'
	end
	
	if (@result = 0)
	begin
		set @now = getutcdate()

		if (@operationType = 0) or (@operationType = 2)
		begin
MapKeyToInstanceId:
			set @loadedByKey = 0
			set @createKey = 0
			
			select @surrogateInstanceId = [SurrogateInstanceId],
				   @keyIsAssociated = [IsAssociated]
			from [KeysTable]
			where [Id] = @keyToLoadBy
			
			if (@@rowcount = 0)
			begin
				if (@operationType = 2)
				begin
					set @result = 4
					select @result as 'Result', @keyToLoadBy 
				end
					set @createKey = 1
			end
			else if (@keyIsAssociated = 0)
			begin
				set @result = 8
				select @result as 'Result', @keyToLoadBy
			end
			else
			begin
				select @instanceId = [Id]
				from [InstancesTable]
				where [SurrogateInstanceId] = @surrogateInstanceId

				if (@@rowcount = 0)
					goto MapKeyToInstanceId

				set @loadedByKey = 1
			end
		end
	end

	if (@result = 0)
	begin
LockOrCreateInstance:
		exec [System.Activities.DurableInstancing].[LockInstance] @instanceId, @surrogateLockOwnerId, @handleInstanceVersion, @handleIsBoundToLock, @surrogateInstanceId output, null, @result output
														  
		if (@result = 0 and @surrogateInstanceId = 0)
		begin
			if (@loadedByKey = 1)
				goto MapKeyToInstanceId
			
			if (@operationType > 1)
			begin
				set @result = 1
				select @result as 'Result', @instanceId as 'InstanceId'
			end
			else
			begin				
				exec [System.Activities.DurableInstancing].[CreateInstance] @instanceId, @surrogateLockOwnerId, null, null, @surrogateInstanceId output, @result output
			
				if (@result = 0 and @surrogateInstanceId = 0)
					goto LockOrCreateInstance
				else if (@surrogateInstanceId > 0)
					set @createdInstance = 1
			end
		end
		else if (@result = 0)
		begin
			delete from [RunnableInstancesTable]
			where [SurrogateInstanceId] = @surrogateInstanceId
		end
	end
		
	if (@result = 0)
	begin
		if (@createKey = 1) 
		begin
			select @isInitialized = [IsInitialized]
			from [InstancesTable]
			where [SurrogateInstanceId] = @surrogateInstanceId
			
			if (@isInitialized = 1)
			begin
				set @result = 5
				select @result as 'Result', @instanceId
			end
			else
			begin													
				insert into [KeysTable] ([Id], [SurrogateInstanceId], [IsAssociated])
				values (@keyToLoadBy, @surrogateInstanceId, 1)
				
				if (@@rowcount = 0)
				begin
					if (@createdInstance = 1)
					begin
						delete [InstancesTable]
						where [SurrogateInstanceId] = @surrogateInstanceId
					end
					else
					begin
						update [InstancesTable]
						set [SurrogateLockOwnerId] = null
						where [SurrogateInstanceId] = @surrogateInstanceId
					end
					
					goto MapKeyToInstanceId
				end
			end
		end
		else if (@loadedByKey = 1 and not exists(select [Id] from [KeysTable] where ([Id] = @keyToLoadBy) and ([IsAssociated] = 1)))
		begin
			set @result = 8
			select @result as 'Result', @keyToLoadBy
		end
		
		if (@operationType > 1 and not exists(select [Id] from [InstancesTable] where ([Id] = @instanceId) and ([IsInitialized] = 1)))
		begin
			set @result = 1
			select @result as 'Result', @instanceId as 'InstanceId'
		end
		
		if (@result = 0)
			exec @result = [System.Activities.DurableInstancing].[AssociateKeys] @surrogateInstanceId, @keysToAssociate, @concatenatedKeyProperties, @encodingOption, @singleKeyId
		
		-- Ensure that this key's data will never be overwritten.
		if (@result = 0 and @createKey = 1)
		begin
			update [KeysTable]
			set [EncodingOption] = @encodingOption
			where [Id] = @keyToLoadBy
		end
	end
	
	if (@result != 13)
		exec sp_releaseapplock @Resource = 'InstanceStoreLock'
		
	if (@result = 0)
	begin
		select @result as 'Result',
			   [Id],
			   [SurrogateInstanceId],
			   [PrimitiveDataProperties],
			   [ComplexDataProperties],
			   [MetadataProperties],
			   [DataEncodingOption],
			   [MetadataEncodingOption],
			   [Version],
			   [IsInitialized],
			   @createdInstance
		from [InstancesTable]
		where [SurrogateInstanceId] = @surrogateInstanceId
		
		if (@createdInstance = 0)
		begin
			select @result as 'Result',
				   [EncodingOption],
				   [Change]
			from [InstanceMetadataChangesTable]
			where [SurrogateInstanceId] = @surrogateInstanceId
			order by([ChangeTime])
			
			if (@@rowcount = 0)
			select @result as 'Result', null, null
				
			select @result as 'Result',
				   [Id],
				   [IsAssociated],
				   [EncodingOption],
				   [Properties]
			from [KeysTable] with (index(NCIX_KeysTable_SurrogateInstanceId))
			where ([KeysTable].[SurrogateInstanceId] = @surrogateInstanceId)
			
			if (@@rowcount = 0)
				select @result as 'Result', null, null, null, null
		end

		commit transaction
	end
	else if (@result = 2 or @result = 14)
		commit transaction
	else
		rollback transaction
end
go

grant execute on [System.Activities.DurableInstancing].[LoadInstance] to [System.Activities.DurableInstancing.InstanceStoreUsers] 
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[TryLoadRunnableInstance]') and type in (N'P', N'PC'))
	drop procedure [System.Activities.DurableInstancing].[TryLoadRunnableInstance]
go

create procedure [System.Activities.DurableInstancing].[TryLoadRunnableInstance]
	@surrogateLockOwnerId bigint,
	@workflowHostType uniqueidentifier,
	@operationType tinyint,
	@handleInstanceVersion bigint,
	@handleIsBoundToLock bit,
	@encodingOption tinyint,	
	@operationTimeout int
as
begin
	set nocount on
	set transaction isolation level read committed	
	set xact_abort on;	
	set deadlock_priority -6
	begin tran
	
	declare @instanceId uniqueIdentifier
	declare @now datetime
	set @now = getutcdate()
	
	declare @workflowIdentityFilter tinyint
	
	select @workflowIdentityFilter = [WorkflowIdentityFilter]
	from [LockOwnersTable]
	where [LockOwnersTable].SurrogateLockOwnerId = @surrogateLockOwnerId
	
	if (@workflowIdentityFilter = null)
		set @workflowIdentityFilter = 0
		
	if (@workflowIdentityFilter = 1)
	begin
		-- Load any Runnable instances of specified WorkflowHostType
		select top (1) @instanceId = instances.[Id]
		from [RunnableInstancesTable] runnableInstances with (readpast, updlock)
			inner loop join [InstancesTable] instances with (readpast, updlock)
			on runnableInstances.[SurrogateInstanceId] = instances.[SurrogateInstanceId]
		where runnableInstances.[WorkflowHostType] = @workflowHostType
			  and 
			  runnableInstances.[RunnableTime] <= @now	
	end
	else if (@workflowIdentityFilter = 2)
	begin
		declare @AnyRevisionFilter table
		(
			DefinitionIdentityAnyRevisionHash uniqueidentifier
			UNIQUE (DefinitionIdentityAnyRevisionHash)
		)

		insert into @AnyRevisionFilter 
		select distinct [DefinitionIdentityAnyRevisionHash]
		from [DefinitionIdentityTable] as IdentityTable, [IdentityOwnerTable] as IdentityOwnerTable
		where IdentityOwnerTable.[SurrogateLockOwnerId] = @surrogateLockOwnerId 
			and 
			IdentityTable.[SurrogateIdentityId] = IdentityOwnerTable.[SurrogateIdentityId]
	
		-- Load Runnables instances of specified WorkflowHostType and ignore revision field on supported identities. 
		select top (1) @instanceId = instances.[Id]
		from [RunnableInstancesTable] runnableInstances with (readpast, updlock)
			inner loop join [InstancesTable] instances with (readpast, updlock)
			on runnableInstances.[SurrogateInstanceId] = instances.[SurrogateInstanceId]
			inner loop join (
						select IdentityTable.[SurrogateIdentityId] as IdentityId
						from [System.Activities.DurableInstancing].[DefinitionIdentityTable] as IdentityTable, @AnyRevisionFilter as AnyRevision
						where IdentityTable.[DefinitionIdentityAnyRevisionHash] = AnyRevision.DefinitionIdentityAnyRevisionHash
					) as FilteredIdentities 
			on runnableInstances.SurrogateIdentityId = FilteredIdentities.IdentityId
		where runnableInstances.[WorkflowHostType] = @workflowHostType
			  and 
			  runnableInstances.[RunnableTime] <= @now	  			
	end
	else
	begin
		-- Load Runnable instances of specified WorkflowHostType and the supported identities
		select top (1) @instanceId = instances.[Id]
		from [RunnableInstancesTable] runnableInstances with (readpast, updlock)
			inner loop join [InstancesTable] instances with (readpast, updlock)
			on runnableInstances.[SurrogateInstanceId] = instances.[SurrogateInstanceId]
			inner loop join (
				select [SurrogateIdentityId] as IdentityId 
				from [IdentityOwnerTable] 
				where [SurrogateLockOwnerId] = @surrogateLockOwnerId
			) as FilteredIdentities  
			on runnableInstances.[SurrogateIdentityId] = FilteredIdentities.IdentityId
		where runnableInstances.[WorkflowHostType] = @workflowHostType
			  and 
			  runnableInstances.[RunnableTime] <= @now
	end	       

    if (@@rowcount = 1)
    begin
		select 0 as 'Result', cast(1 as bit)				
		exec [System.Activities.DurableInstancing].[LoadInstance] @surrogateLockOwnerId, @operationType, @handleInstanceVersion, @handleIsBoundToLock, null, @instanceId, null, @encodingOption, null, null, @operationTimeout
    end	
    else
    begin
		select 0 as 'Result', cast(0 as bit)
    end
    
    if (@@trancount > 0)
    begin
		commit tran
    end
end
go

grant execute on [System.Activities.DurableInstancing].[TryLoadRunnableInstance] to [System.Activities.DurableInstancing.InstanceStoreUsers] 
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[DeleteInstance]') and type in (N'P', N'PC'))
	drop procedure [System.Activities.DurableInstancing].[DeleteInstance]
go
create procedure [System.Activities.DurableInstancing].[DeleteInstance]
	@surrogateInstanceId bigint = null
as
begin	
	set nocount on
	set transaction isolation level read committed		
	set xact_abort on;	
	
	delete [InstancePromotedPropertiesTable]
	where [SurrogateInstanceId] = @surrogateInstanceId
		
	delete [KeysTable]
	where [SurrogateInstanceId] = @surrogateInstanceId
		
	delete [InstanceMetadataChangesTable]
	where [SurrogateInstanceId] = @surrogateInstanceId

	delete [RunnableInstancesTable] 
	where [SurrogateInstanceId] = @surrogateInstanceId

	delete [InstancesTable] 
	where [SurrogateInstanceId] = @surrogateInstanceId

end
go

grant execute on [System.Activities.DurableInstancing].[DeleteInstance] to [System.Activities.DurableInstancing.InstanceStoreUsers] 
go

if exists (select * from sys.triggers where object_id = OBJECT_ID(N'[System.Activities.DurableInstancing].[DeleteInstanceTrigger]'))
	drop trigger [System.Activities.DurableInstancing].[DeleteInstanceTrigger]
go

create trigger [System.Activities.DurableInstancing].[DeleteInstanceTrigger] on [System.Activities.DurableInstancing].[Instances]
instead of delete
as
begin	
	if (@@rowcount = 0)
		return
		
	set nocount on
	set transaction isolation level read committed		
	set xact_abort on;	
	
	declare @surrogateInstanceIds table ([SurrogateInstanceId] bigint primary key)		
	
	insert into @surrogateInstanceIds
	select [SurrogateInstanceId]
	from deleted as [DeletedInstances]
	join [InstancesTable] on [InstancesTable].[Id] = [DeletedInstances].[InstanceId]
	
	delete [InstancePromotedPropertiesTable]
	from @surrogateInstanceIds as [InstancesToDelete]
	inner merge join [System.Activities.DurableInstancing].[InstancePromotedPropertiesTable] on [InstancePromotedPropertiesTable].[SurrogateInstanceId] = [InstancesToDelete].[SurrogateInstanceId]
	
	delete [KeysTable]
	from @surrogateInstanceIds as [InstancesToDelete]
	inner loop join [System.Activities.DurableInstancing].[KeysTable] on [KeysTable].[SurrogateInstanceId] = [InstancesToDelete].[SurrogateInstanceId]
	
	delete from [InstanceMetadataChangesTable]
	from @surrogateInstanceIds as [InstancesToDelete]
	inner merge join [System.Activities.DurableInstancing].[InstanceMetadataChangesTable] on [InstanceMetadataChangesTable].[SurrogateInstanceId] = [InstancesToDelete].[SurrogateInstanceId]
	
	delete [RunnableInstancesTable]
	from @surrogateInstanceIds as [InstancesToDelete]
	inner loop join [System.Activities.DurableInstancing].[RunnableInstancesTable] on [RunnableInstancesTable].[SurrogateInstanceId] = [InstancesToDelete].[SurrogateInstanceId]
	
	delete [InstancesTable]
	from @surrogateInstanceIds as [InstancesToDelete]
	inner merge join [System.Activities.DurableInstancing].[InstancesTable] on [InstancesTable].[SurrogateInstanceId] = [InstancesToDelete].[SurrogateInstanceId]
end
go	

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[CreateServiceDeployment]') and type in (N'P', N'PC'))
	drop procedure [System.Activities.DurableInstancing].[CreateServiceDeployment]
go
create procedure [System.Activities.DurableInstancing].[CreateServiceDeployment]	
	@serviceDeploymentHash uniqueIdentifier,
	@siteName nvarchar(max),
	@relativeServicePath nvarchar(max),
	@relativeApplicationPath nvarchar(max),
	@serviceName nvarchar(max),
    @serviceNamespace nvarchar(max),
    @serviceDeploymentId bigint output
as
begin
	set nocount on
	set transaction isolation level read committed		
	set xact_abort on;	
	
		--Create or select the service deployment id
		insert into [ServiceDeploymentsTable]
			([ServiceDeploymentHash], [SiteName], [RelativeServicePath], [RelativeApplicationPath], [ServiceName], [ServiceNamespace])
			values (@serviceDeploymentHash, @siteName, @relativeServicePath, @relativeApplicationPath, @serviceName, @serviceNamespace)
			
		if (@@rowcount = 0)
		begin		
			select @serviceDeploymentId = [Id]
			from [ServiceDeploymentsTable]
			where [ServiceDeploymentHash] = @serviceDeploymentHash		
		end
		else			
		begin
			set @serviceDeploymentId = scope_identity()		
		end	
		
		select 0 as 'Result', @serviceDeploymentId		
end	
go

grant execute on [System.Activities.DurableInstancing].[CreateServiceDeployment] to [System.Activities.DurableInstancing.InstanceStoreUsers] 
go

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[SaveInstance]') and type in (N'P', N'PC'))
	drop procedure [System.Activities.DurableInstancing].[SaveInstance]
go
create procedure [System.Activities.DurableInstancing].[SaveInstance]
	@instanceId uniqueidentifier,
	@surrogateLockOwnerId bigint,
	@handleInstanceVersion bigint,
	@handleIsBoundToLock bit,
	@primitiveDataProperties varbinary(max),
	@complexDataProperties varbinary(max),
	@writeOnlyPrimitiveDataProperties varbinary(max),
	@writeOnlyComplexDataProperties varbinary(max),
	@metadataProperties varbinary(max),
	@metadataIsConsistent bit,
	@encodingOption tinyint,
	@timerDurationMilliseconds bigint,
	@suspensionStateChange tinyint,
	@suspensionReason nvarchar(max),
	@suspensionExceptionName nvarchar(450),
	@keysToAssociate xml,
	@keysToComplete xml,
	@keysToFree xml,
	@concatenatedKeyProperties varbinary(max),
	@unlockInstance bit,
	@isReadyToRun bit,
	@isCompleted bit,
	@singleKeyId uniqueidentifier,
	@lastMachineRunOn nvarchar(450),
	@executionStatus nvarchar(450),
	@blockingBookmarks nvarchar(max),
	@workflowHostType uniqueidentifier,
	@serviceDeploymentId bigint,
	@operationTimeout int,
	@identityMetadata xml = null
as
begin
	set nocount on
	set transaction isolation level read committed		
	set xact_abort on;	

	declare @currentInstanceVersion bigint
	declare @deleteInstanceOnCompletion bit
	declare @enqueueCommand bit
	declare @isSuspended bit
	declare @lockAcquired bigint
	declare @metadataUpdateOnly bit
	declare @now datetime
	declare @result int
	declare @surrogateInstanceId bigint
	declare @pendingTimer datetime
	declare @definitionIdentityHash uniqueidentifier
	declare @surrogateIdentityId bigint

	set @result = 0
	set @metadataUpdateOnly = 0
	
	exec @lockAcquired = sp_getapplock @Resource = 'InstanceStoreLock', @LockMode = 'Shared', @LockTimeout = @operationTimeout
		
	if (@lockAcquired < 0)
	begin
		select @result as 'Result'
		set @result = 13
	end
	
	set @now = getutcdate()
	
	if (@primitiveDataProperties is null and @complexDataProperties is null and @writeOnlyPrimitiveDataProperties is null and @writeOnlyComplexDataProperties is null)
		set @metadataUpdateOnly = 1

LockOrCreateInstance:
	if (@result = 0)
	begin
		exec [System.Activities.DurableInstancing].[LockInstance] @instanceId, @surrogateLockOwnerId, @handleInstanceVersion, @handleIsBoundToLock, @surrogateInstanceId output, @currentInstanceVersion output, @result output
															  
		if (@result = 0 and @surrogateInstanceId = 0)
		begin
			exec [System.Activities.DurableInstancing].[CreateInstance] @instanceId, @surrogateLockOwnerId, @workflowHostType, @serviceDeploymentId, @surrogateInstanceId output, @result output
			
			if (@result = 0 and @surrogateInstanceId = 0)
				goto LockOrCreateInstance
			
			set @currentInstanceVersion = 1
		end
	end
	
	if (@result = 0)
	begin
		select @enqueueCommand = [EnqueueCommand],
			   @deleteInstanceOnCompletion = [DeletesInstanceOnCompletion]
		from [LockOwnersTable]
		where ([SurrogateLockOwnerId] = @surrogateLockOwnerId)
		
		if (@isCompleted = 1 and @deleteInstanceOnCompletion = 1)
		begin
			exec [System.Activities.DurableInstancing].[DeleteInstance] @surrogateInstanceId
			goto Finally
		end
		
		if @identityMetadata is not null
		begin
			select @definitionIdentityHash = T.Item.value('DefinitionIdentityHash[1]', 'uniqueidentifier') 
			from @identityMetadata.nodes('/IdentityMetadata/IdentityCollection/Identity') as T(Item)
			
			if (@definitionIdentityHash is null)
			begin
				set @result = 15
				goto Finally 
			end
			else
			begin
				if not exists (
					select 1
					from [DefinitionIdentityTable]
					where [DefinitionIdentityHash] = @definitionIdentityHash
					)
				begin
					--insert the new identity
					exec [System.Activities.DurableInstancing].[InsertDefinitionIdentity] @identityMetadata
				end

                select @surrogateIdentityId = [SurrogateIdentityId]
                from [DefinitionIdentityTable]
                where ([DefinitionIdentityHash] = @definitionIdentityHash)
			end
		end
		
		update [InstancesTable] 
		set @instanceId = [InstancesTable].[Id],
			@workflowHostType = [WorkflowHostType] = 
					case when (@workflowHostType is null)
						then [WorkflowHostType]
						else @workflowHostType 
					end,
			@serviceDeploymentId = [ServiceDeploymentId] = 
					case when (@serviceDeploymentId is null)
						then [ServiceDeploymentId]
						else @serviceDeploymentId 
					end,
			@pendingTimer = [PendingTimer] = 
					case when (@metadataUpdateOnly = 1)
						then [PendingTimer]
						else [System.Activities.DurableInstancing].[GetExpirationTime](@timerDurationMilliseconds)
					end,
			@isReadyToRun = [IsReadyToRun] = 
					case when (@metadataUpdateOnly = 1)
						then [IsReadyToRun]
						else @isReadyToRun
					end,
			@isSuspended = [IsSuspended] = 
					case when (@suspensionStateChange = 0) then [IsSuspended]
						 when (@suspensionStateChange = 1) then 1
						 else 0
					end,
			[SurrogateLockOwnerId] = case when (@unlockInstance = 1 or @isCompleted = 1)
										then null
										else @surrogateLockOwnerId
									 end,
			[PrimitiveDataProperties] = case when (@metadataUpdateOnly = 1)
										then [PrimitiveDataProperties]
										else @primitiveDataProperties
									   end,
			[ComplexDataProperties] = case when (@metadataUpdateOnly = 1)
										then [ComplexDataProperties]
										else @complexDataProperties
									   end,
			[WriteOnlyPrimitiveDataProperties] = case when (@metadataUpdateOnly = 1)
										then [WriteOnlyPrimitiveDataProperties]
										else @writeOnlyPrimitiveDataProperties
									   end,
			[WriteOnlyComplexDataProperties] = case when (@metadataUpdateOnly = 1)
										then [WriteOnlyComplexDataProperties]
										else @writeOnlyComplexDataProperties
									   end,
			[MetadataProperties] = case
									 when (@metadataIsConsistent = 1) then @metadataProperties
									 else [MetadataProperties]
								   end,
			[SuspensionReason] = case
									when (@suspensionStateChange = 0) then [SuspensionReason]
									when (@suspensionStateChange = 1) then @suspensionReason
									else null
								 end,
			[SuspensionExceptionName] = case
									when (@suspensionStateChange = 0) then [SuspensionExceptionName]
									when (@suspensionStateChange = 1) then @suspensionExceptionName
									else null
								 end,
			[IsCompleted] = @isCompleted,
			[IsInitialized] = case
								when (@metadataUpdateOnly = 0) then 1
								else [IsInitialized]
							  end,
			[DataEncodingOption] = case
									when (@metadataUpdateOnly = 0) then @encodingOption
									else [DataEncodingOption]
								   end,
			[MetadataEncodingOption] = case
									when (@metadataIsConsistent = 1) then @encodingOption
									else [MetadataEncodingOption]
								   end,
			[BlockingBookmarks] = case
									when (@metadataUpdateOnly = 0) then @blockingBookmarks
									else [BlockingBookmarks]
								  end,
			[LastUpdated] = @now,
			[LastMachineRunOn] = case
									when (@metadataUpdateOnly = 0) then @lastMachineRunOn
									else [LastMachineRunOn]
								 end,
			[ExecutionStatus] = case
									when (@metadataUpdateOnly = 0) then @executionStatus
									else [ExecutionStatus]
								end,
			@surrogateIdentityId = [SurrogateIdentityId] = 
								case
									when (@identityMetadata is null) then [SurrogateIdentityId]
									else @surrogateIdentityId
								end
		from [InstancesTable]		
		where ([InstancesTable].[SurrogateInstanceId] = @surrogateInstanceId)
	
		if (@@rowcount = 0)
		begin
			set @result = 99
			select @result as 'Result' 
		end
		else
		begin
			if (@keysToAssociate is not null or @singleKeyId is not null)
				exec @result = [System.Activities.DurableInstancing].[AssociateKeys] @surrogateInstanceId, @keysToAssociate, @concatenatedKeyProperties, @encodingOption, @singleKeyId
			
			if (@result = 0 and @keysToComplete is not null)
				exec @result = [System.Activities.DurableInstancing].[CompleteKeys] @surrogateInstanceId, @keysToComplete
			
			if (@result = 0 and @keysToFree is not null)
				exec @result = [System.Activities.DurableInstancing].[FreeKeys] @surrogateInstanceId, @keysToFree
			
			if (@result = 0) and (@metadataUpdateOnly = 0)
			begin
				delete from [InstancePromotedPropertiesTable]
				where [SurrogateInstanceId] = @surrogateInstanceId
			end
			
			if (@result = 0)
			begin
				if (@metadataIsConsistent = 1)
				begin
					delete from [InstanceMetadataChangesTable]
					where [SurrogateInstanceId] = @surrogateInstanceId
				end
				else if (@metadataProperties is not null)
				begin
					insert into [InstanceMetadataChangesTable] ([SurrogateInstanceId], [EncodingOption], [Change])
					values (@surrogateInstanceId, @encodingOption, @metadataProperties)
				end
			end
			
			if (@result = 0 and @unlockInstance = 1 and @isCompleted = 0)
				exec [System.Activities.DurableInstancing].[InsertRunnableInstanceEntry] @surrogateInstanceId, @workflowHostType, @serviceDeploymentId, @isSuspended, @isReadyToRun, @pendingTimer, @surrogateIdentityId	
		end
	end

Finally:
	if (@result != 13)
		exec sp_releaseapplock @Resource = 'InstanceStoreLock'
	
	if (@result = 0)
		select @result as 'Result', @currentInstanceVersion

	return @result
end
go

grant execute on [System.Activities.DurableInstancing].[SaveInstance] to [System.Activities.DurableInstancing.InstanceStoreUsers] 
go

if exists (select * from sys.triggers where object_id = OBJECT_ID(N'[System.Activities.DurableInstancing].[DeleteServiceDeploymentTrigger]'))
	drop trigger [System.Activities.DurableInstancing].[DeleteServiceDeploymentTrigger]
go

create trigger [System.Activities.DurableInstancing].[DeleteServiceDeploymentTrigger] on [System.Activities.DurableInstancing].[ServiceDeployments]
instead of delete
as
begin	
	if (@@rowcount = 0)
		return	
		
	set nocount on
	set transaction isolation level read committed		
	set xact_abort on;	
	
	declare @lockAcquired bigint
	declare @candidateDeploymentIdsPass1 table([Id] bigint primary key)
	
	exec @lockAcquired = sp_getapplock @Resource = 'InstanceStoreLock', @LockMode = 'Exclusive', @LockTimeout = 25000
	
	if (@lockAcquired < 0)
		return

	insert into @candidateDeploymentIdsPass1
	select [ServiceDeploymentId] from deleted
	except
	select [ServiceDeploymentId] from [InstancesTable]
	
	delete [ServiceDeploymentsTable]
	from [ServiceDeploymentsTable]
	join @candidateDeploymentIdsPass1 as [OrphanedIds] on [OrphanedIds].[Id] = [ServiceDeploymentsTable].[Id]
	
	exec sp_releaseapplock @Resource = 'InstanceStoreLock'
end
go	

if exists (select * from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[InsertPromotedProperties]') and type in (N'P', N'PC'))
	drop procedure [System.Activities.DurableInstancing].[InsertPromotedProperties]
go

create procedure [System.Activities.DurableInstancing].[InsertPromotedProperties]
	@instanceId uniqueidentifier,
	@promotionName nvarchar(400),
	@value1 sql_variant = null,
	@value2 sql_variant = null,
	@value3 sql_variant = null,
	@value4 sql_variant = null,
	@value5 sql_variant = null,
	@value6 sql_variant = null,
	@value7 sql_variant = null,
	@value8 sql_variant = null,
	@value9 sql_variant = null,
	@value10 sql_variant = null,
	@value11 sql_variant = null,
	@value12 sql_variant = null,
	@value13 sql_variant = null,
	@value14 sql_variant = null,
	@value15 sql_variant = null,
	@value16 sql_variant = null,
	@value17 sql_variant = null,
	@value18 sql_variant = null,
	@value19 sql_variant = null,
	@value20 sql_variant = null,
	@value21 sql_variant = null,
	@value22 sql_variant = null,
	@value23 sql_variant = null,
	@value24 sql_variant = null,
	@value25 sql_variant = null,
	@value26 sql_variant = null,
	@value27 sql_variant = null,
	@value28 sql_variant = null,
	@value29 sql_variant = null,
	@value30 sql_variant = null,
	@value31 sql_variant = null,
	@value32 sql_variant = null,
	@value33 varbinary(max) = null,
	@value34 varbinary(max) = null,
	@value35 varbinary(max) = null,
	@value36 varbinary(max) = null,
	@value37 varbinary(max) = null,
	@value38 varbinary(max) = null,
	@value39 varbinary(max) = null,
	@value40 varbinary(max) = null,
	@value41 varbinary(max) = null,
	@value42 varbinary(max) = null,
	@value43 varbinary(max) = null,
	@value44 varbinary(max) = null,
	@value45 varbinary(max) = null,
	@value46 varbinary(max) = null,
	@value47 varbinary(max) = null,
	@value48 varbinary(max) = null,
	@value49 varbinary(max) = null,
	@value50 varbinary(max) = null,
	@value51 varbinary(max) = null,
	@value52 varbinary(max) = null,
	@value53 varbinary(max) = null,
	@value54 varbinary(max) = null,
	@value55 varbinary(max) = null,
	@value56 varbinary(max) = null,
	@value57 varbinary(max) = null,
	@value58 varbinary(max) = null,
	@value59 varbinary(max) = null,
	@value60 varbinary(max) = null,
	@value61 varbinary(max) = null,
	@value62 varbinary(max) = null,
	@value63 varbinary(max) = null,
	@value64 varbinary(max) = null
as
begin
	set nocount on
	set transaction isolation level read committed		
	set xact_abort on;	

	declare @surrogateInstanceId bigint

	select @surrogateInstanceId = [SurrogateInstanceId]
	from [InstancesTable]
	where [Id] = @instanceId

	insert into [System.Activities.DurableInstancing].[InstancePromotedPropertiesTable]
	values (@surrogateInstanceId, @promotionName, @value1, @value2, @value3, @value4, @value5, @value6, @value7, @value8,
			@value9, @value10, @value11, @value12, @value13, @value14, @value15, @value16, @value17, @value18, @value19,
			@value20, @value21, @value22, @value23, @value24, @value25, @value26, @value27, @value28, @value29, @value30,
			@value31, @value32, @value33, @value34, @value35, @value36, @value37, @value38, @value39, @value40, @value41,
			@value42, @value43, @value44, @value45, @value46, @value47, @value48, @value49, @value50, @value51, @value52,
			@value53, @value54, @value55, @value56, @value57, @value58, @value59, @value60, @value61, @value62, @value63,
			@value64)
end
go

grant execute on [System.Activities.DurableInstancing].[InsertPromotedProperties] to [System.Activities.DurableInstancing.InstanceStoreUsers]
go


if exists (select 1 from sys.objects where object_id = object_id(N'[System.Activities.DurableInstancing].[GetWorkflowInstanceStoreVersion]') and type in (N'P', N'PC'))
	drop procedure [System.Activities.DurableInstancing].[GetWorkflowInstanceStoreVersion]
go

create procedure [System.Activities.DurableInstancing].[GetWorkflowInstanceStoreVersion]
as
begin
	set nocount on
	set transaction isolation level read committed		
	set xact_abort on;	
		
	select		Major
				,Minor
				,Build
				,Revision
	from		[System.Activities.DurableInstancing].[SqlWorkflowInstanceStoreVersionTable]
	
end	
go

grant execute on [System.Activities.DurableInstancing].[GetWorkflowInstanceStoreVersion] to [System.Activities.DurableInstancing.InstanceStoreUsers] 
go

grant execute on [System.Activities.DurableInstancing].[GetWorkflowInstanceStoreVersion] to [System.Activities.DurableInstancing.WorkflowActivationUsers] 
go
