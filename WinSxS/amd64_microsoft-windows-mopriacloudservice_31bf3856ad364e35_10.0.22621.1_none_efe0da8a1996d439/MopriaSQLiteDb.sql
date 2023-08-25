-- To generate the database from the script we would issue the following command (replacing the name):
--      sqlite3 Database.db < MopriaSQLiteDb.sql
SELECT 1;
PRAGMA foreign_keys=ON;
BEGIN TRANSACTION;
CREATE TABLE [Pdls] (
  [ID] INTEGER NOT NULL
, [pdl] ntext NULL
, CONSTRAINT [PK_dbo.Pdls] PRIMARY KEY ([ID])
);
CREATE TABLE [Locations] (
  [ID] INTEGER NOT NULL
, [latitude] real NULL
, [longitude] real NULL
, [altitude] int NULL
, [organization] ntext NULL
, [site] ntext NULL
, [building] ntext NULL
, [floor_number] int NULL
, [floor_name] ntext NULL
, [floor_grid] ntext NULL
, [room_name] ntext NULL
, [street_address] ntext NULL
, [sub_unit] ntext NULL
, [locality] ntext NULL
, [region] ntext NULL
, [postal_code] ntext NULL
, [country] ntext NULL
, [full_address] ntext NULL
, [OrgAttrsPresent] bit NOT NULL
, [AddressTreeAttrsPresent] bit NOT NULL
, [LastOrgAttrName] ntext NULL
, [LastAddressTreeAttrName] ntext NULL
, [OrgLocationStr] ntext NULL
, CONSTRAINT [PK_dbo.Locations] PRIMARY KEY ([ID])
);
CREATE TABLE [DeviceTypes] (
  [ID] INTEGER NOT NULL
, [type] ntext NULL
, CONSTRAINT [PK_dbo.DeviceTypes] PRIMARY KEY ([ID])
);
CREATE TABLE [Devices] (
  [ID] INTEGER NOT NULL
, [uuid] ntext NULL
, [sddl] ntext NULL
, [LocationID] int NULL
, CONSTRAINT [PK_dbo.Devices] PRIMARY KEY ([ID])
, FOREIGN KEY ([LocationID]) REFERENCES [Locations] ([ID]) ON DELETE NO ACTION ON UPDATE NO ACTION
);
CREATE TABLE [DeviceTypeDeviceAssociations] (
  [DeviceTypeID] int NOT NULL
, [DeviceID] int NOT NULL
, CONSTRAINT [PK_dbo.DeviceTypeDeviceAssociations] PRIMARY KEY ([DeviceTypeID],[DeviceID])
, FOREIGN KEY ([DeviceID]) REFERENCES [Devices] ([ID]) ON DELETE CASCADE ON UPDATE CASCADE
, FOREIGN KEY ([DeviceTypeID]) REFERENCES [DeviceTypes] ([ID]) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE [DeviceNames] (
  [ID] INTEGER NOT NULL
, [manufacturer] ntext NULL
, [model] ntext NULL
, [name] ntext NULL
, [comment] ntext NULL
, [lang] ntext NULL
, [DeviceID] int NULL
, CONSTRAINT [PK_dbo.DeviceNames] PRIMARY KEY ([ID])
, FOREIGN KEY ([DeviceID]) REFERENCES [Devices] ([ID]) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE [Details] (
  [ID] INTEGER NOT NULL
, [type] ntext NULL
, [Namespace] ntext NULL
, [duplex] bit NULL
, [color] bit NULL
, [pay_for_use] bit NULL
, [DeviceID] int NULL
, CONSTRAINT [PK_dbo.Details] PRIMARY KEY ([ID])
, FOREIGN KEY ([DeviceID]) REFERENCES [Devices] ([ID]) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE [PdlDetailAssociations] (
  [PdlID] int NOT NULL
, [DetailID] int NOT NULL
, CONSTRAINT [PK_dbo.PdlDetailAssociations] PRIMARY KEY ([PdlID],[DetailID])
, FOREIGN KEY ([DetailID]) REFERENCES [Details] ([ID]) ON DELETE CASCADE ON UPDATE CASCADE
, FOREIGN KEY ([PdlID]) REFERENCES [Pdls] ([ID]) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE [Links] (
  [ID] INTEGER NOT NULL
, [rel] ntext NULL
, [type] ntext NULL
, [value] ntext NULL
, [href] ntext NULL
, [description] ntext NULL
, [DetailID] int NULL
, [DeviceID] int NULL
, CONSTRAINT [PK_dbo.Links] PRIMARY KEY ([ID])
, FOREIGN KEY ([DetailID]) REFERENCES [Details] ([ID]) ON DELETE CASCADE ON UPDATE CASCADE
, FOREIGN KEY ([DeviceID]) REFERENCES [Devices] ([ID]) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE [Comments] (
  [ID] INTEGER NOT NULL
, [comment] ntext NULL
, [lang] ntext NULL
, [DetailID] int NULL
, CONSTRAINT [PK_dbo.Comments] PRIMARY KEY ([ID])
, FOREIGN KEY ([DetailID]) REFERENCES [Details] ([ID]) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Indices for optimized ID searching
CREATE INDEX [IX_LocationID_Devices] ON [Devices] ([LocationID] ASC);
CREATE INDEX [IX_DeviceID_DeviceTypeDeviceAssociations] ON [DeviceTypeDeviceAssociations] ([DeviceID] ASC);
CREATE INDEX [IX_DeviceTypeID_DeviceTypeDeviceAssociations] ON [DeviceTypeDeviceAssociations] ([DeviceTypeID] ASC);
CREATE INDEX [IX_DeviceID_DeviceNames] ON [DeviceNames] ([DeviceID] ASC);
CREATE INDEX [IX_DeviceID_Details] ON [Details] ([DeviceID] ASC);
CREATE INDEX [IX_DetailID_PdlDetailAssociations] ON [PdlDetailAssociations] ([DetailID] ASC);
CREATE INDEX [IX_PdlID_PdlDetailAssociations] ON [PdlDetailAssociations] ([PdlID] ASC);
CREATE INDEX [IX_DetailID_Links] ON [Links] ([DetailID] ASC);
CREATE INDEX [IX_DeviceID_Links] ON [Links] ([DeviceID] ASC);
CREATE INDEX [IX_DetailID_Comments] ON [Comments] ([DetailID] ASC);

-- Index for optimized search for uuid
CREATE INDEX [IX_UUID_Devices] ON [Devices] ([uuid] ASC);

-- Indices for optimized search for keywords
CREATE INDEX [IX_Manufacturer_DeviceNames] ON [DeviceNames] ([manufacturer] ASC, [DeviceID]);
CREATE INDEX [IX_Model_DeviceNames] ON [DeviceNames] ([model] ASC, [DeviceID]);
CREATE INDEX [IX_Name_DeviceNames] ON [DeviceNames] ([name] ASC, [DeviceID]);
CREATE INDEX [IX_Comment_DeviceNames] ON [DeviceNames] ([comment] ASC, [DeviceID]);
CREATE INDEX [IX_Comment_Comments] ON [Comments] ([comment] ASC, [DetailID]);

-- Indices for optimized location searching
CREATE INDEX [IX_Longitude_Locations] ON [Locations] ([longitude] ASC, [latitude]);
CREATE INDEX [IX_Latitude_Locations] ON [Locations] ([latitude] ASC, [longitude]);
CREATE INDEX [IX_OrgLocationStr_Locations] ON [Locations] ([OrgLocationStr] ASC);

COMMIT;
