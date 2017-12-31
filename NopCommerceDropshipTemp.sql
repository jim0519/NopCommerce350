
--insert top categories
insert into Category
select 
CategoryName,
null as Description,
1 as CategoryTemplateId,
CategoryID as MetaKeywords,
null as MetaDescription,
null as MetaTitle,
0 as ParentCategoryId,
0 as PictureId,
20 as PageSize,
1 as AllowCustomersToSelectPageSize,
'20,40,60' as PageSizeOptions,
null as PriceRanges,
0 as ShowOnHomePage,
1 as IncludeInTopMenu,
0 as HasDiscountsApplied,
0 as SubjectToAcl,
0 as LimitedToStores,
1 as Published,
0 as Deleted,
row_number() over (order by categoryName) as DisplayOrder,
getdate() as CreatedOnUtc,
GETDATE() as UpdatedOnUtc

from AutoPostAdDropship.dbo.V_ProductCategory
where CategoryTypeID=4
and Status='A' 
and CategoryID<200
and CategoryLevel=3





--insert second level category

insert into NopCommerce.dbo.Category
select 
CategoryName,
null as Description,
1 as CategoryTemplateId,
CategoryID as MetaKeywords,
null as MetaDescription,
null as MetaTitle,
ISNULL(NC.Id,0) as ParentCategoryId,
0 as PictureId,
20 as PageSize,
1 as AllowCustomersToSelectPageSize,
'20,40,60' as PageSizeOptions,
null as PriceRanges,
0 as ShowOnHomePage,
1 as IncludeInTopMenu,
0 as HasDiscountsApplied,
0 as SubjectToAcl,
0 as LimitedToStores,
1 as Published,
0 as Deleted,
row_number() over (order by categoryName) as DisplayOrder,
getdate() as CreatedOnUtc,
GETDATE() as UpdatedOnUtc

from AutoPostAdDropship.dbo.V_ProductCategory DC
left join NopCommerce.dbo.Category NC on DC.ParentCategoryID=ISNULL(NC.MetaKeywords,0)
where CategoryTypeID=4
and Status='A' 
and CategoryID<200
and CategoryLevel=4




--insert slug for cateogories

insert into NopCommerce.dbo.UrlRecord
select 
Id as EntityId,
'Category' as EntityName,
REPLACE(REPLACE( REPLACE( LOWER(rtrim(ltrim(Name))),' & ','-'),' ','-'),',','') as Slug,
1 as IsActive,
0 as LanguageId
from NopCommerce.dbo.Category
where Deleted=0







--build nopcommerce info

select 
--CEILING(DS.Price*1.2)-0.05 as eBayPrice,
--COALESCE(EOPL.Title, RS.Name,DS.Title) as eBayTitle,
DS.SKU as SKU,
--CEILING((DS.Price+0.3)/0.774)-0.05 as Price,
DS.Price,
COALESCE(EOPL.Title, RS.Name,DS.Title) as Title,
0 as CategoryID,
DS.InventoryQty,
DS.AddressID,
DS.AccountID,
DS.CustomFieldGroupID,
DS.BusinessLogoPath,
DS.Description,
DS.CustomID,
DS.Status,
DS.Postage,
DS.Notes,
DS.AdTypeID
from
(
	select * from AutoPostAdPostData where AdTypeID=4
) DS
left join
(
	select * from RealSmartProduct
) RS on DS.SKU=RS.SKU
left join
(
	select * from AutoPostAdPostData where AdTypeID=5 and Status='A'
) EOPL on DS.SKU=EOPL.SKU



select 
--CEILING(DS.Price*1.2)-0.05 as eBayPrice,
--COALESCE(EOPL.Title, RS.Name,DS.Title) as eBayTitle,
DS.ID,
DS.SKU as SKU,
--CEILING((DS.Price+0.3)/0.774)-0.05 as Price,
DS.Price,
COALESCE(EOPL.Title, RS.Name,DS.Title) as Title,
0 as CategoryID,
DS.InventoryQty,
DS.AddressID,
DS.AccountID,
DS.CustomFieldGroupID,
DS.BusinessLogoPath,
DS.Description,
DS.ImagesPath,
DS.CustomID,
DS.Status,
DS.Postage,
DS.Notes,
DS.AdTypeID
from
(
	select * from AutoPostAdPostData where AdTypeID=4
) DS
left join
(
	select * from RealSmartProduct
) RS on DS.SKU=RS.SKU
left join
(
	select * from AutoPostAdPostData where AdTypeID=5 and Status='A'
) EOPL on DS.SKU=EOPL.SKU
left join
(
	select * from NopCommerce.dbo.Product
) NC on DS.SKU=NC.Sku
where NC.Sku is null
and DS.Status=1














--To modify DropshipStockQty structure, use below command

ALTER TABLE DropshipStockQty ADD
		Price Decimal(18,2) NOT NULL

ALTER TABLE DropshipStockQty ADD
		Status varchar(50) NOT NULL

ALTER TABLE DropshipStockQty ADD
		Cost Decimal(18,2) NOT NULL

ALTER TABLE DropshipStockQty ADD
		IsFreeShipping bit NOT NULL

ALTER TABLE DropshipStockQty ADD
		Postage Decimal(18,2) NOT NULL

ALTER TABLE DropshipStockQty ADD
		RRP Decimal(18,2) NOT NULL




--insert new item to old dropship database

--insert into AutoPostAdDropship.dbo.AutoPostAdPostData
--select 
--New.SKU,
--New.Price,
--New.Title,
--0 as CategoryID,
--New.InventoryQty,
--1 as AddressID,
--1 as AccountID,
--1 as CustomFieldGroupID,
--'' as BusinessLogoPath,
--New.Description,
--'' as ImagesPath,
--'' as CustomID,
--New.StatusID as Status,
--0 as Postage,
--case when New.PostageRuleID=1 then 'FreeShipping' else '' end as Notes,-- will need to change postage rule ID
--4 as AdTypeID,
--1 as ScheduleRuleID
--from 
--(
--select * from Dropship.dbo.D_Item
--where SupplierID=1
--) New 
--left join 
--(
--select *
--from AutoPostAdDropship.dbo.AutoPostAdPostData
--where AdTypeID=4
--) Old on New.SKU=Old.SKU
--where Old.SKU is null

--Fix dropship images data
--ebayService.GetDropshipzoneProductImagesPath();


--update old dropship database


--update  U
----select *
--set InventoryQty=New.InventoryQty,
--Price=New.Price,
--Status=New.StatusID,
--Notes=case when New.PostageRuleID=1 then 'FreeShipping' else '' end,
--Postage=case when Old.Postage=0 then New.MaxPostage else Old.Postage end
--from AutoPostAdDropship.dbo.AutoPostAdPostData U
--inner join
--(
--select *
--from AutoPostAdDropship.dbo.AutoPostAdPostData
--where AdTypeID=4
--) Old on U.ID=Old.ID
--inner join
--(
--	select I.*,isnull(MaxPostage,0) as MaxPostage
--	from Dropship.dbo.D_Item I
--	left join 
--	(
--		select 
--		PostageRuleID,
--		MAX(cast(Formula as decimal(18,2))) as MaxPostage
--		from Dropship.dbo.T_PostageRuleLine
--		group by PostageRuleID
--	) P on I.PostageRuleID=P.PostageRuleID
--	where SupplierID=1
--	--and StatusID=1
--) New on New.SKU=Old.SKU
--and Old.SKU not in ('SCALE-SHOP-40-BK','SCALE-SHOP-40-WH','OTM-L-BK','Scale-TCS-C-150kg','Scale-TCS-C-300kg','OTM-L-LINEN-LI-GY','OTM-L-LINEN-GY','OTM-L-WH','OTM-L-BK','OTM-L-BR','OTM-L-LINEN-BEIGE','OTM-L-LINEN-BLACK','OTM-L-LINEN-BR')

--New update old dropship database

update  U
--select *
set InventoryQty=case when M2.OldSKU is not null then M2.InventoryQty else New.InventoryQty end,
Price=case when M2.OldSKU is not null then M2.Price else New.Price end,
Status=case when M2.OldSKU is not null then M2.StatusID else New.StatusID end,
Notes=(case when M2.OldSKU is not null then (case when M2.PostageRuleID=1 then 'FreeShipping' else '' end) else (case when New.PostageRuleID=1 then 'FreeShipping' else '' end) end),
Postage=case when M2.OldSKU is not null then M2.MaxPostage else New.MaxPostage end
from AutoPostAdDropship.dbo.AutoPostAdPostData U
inner join
(
select *
from AutoPostAdDropship.dbo.AutoPostAdPostData
where AdTypeID=4
) Old on U.ID=Old.ID
inner join
(
	select I.*,isnull(MaxPostage,0) as MaxPostage
	from Dropship.dbo.D_Item I
	left join 
	(
		select 
		PostageRuleID,
		MAX(cast(Formula as decimal(18,2))) as MaxPostage
		from Dropship.dbo.T_PostageRuleLine
		group by PostageRuleID
	) P on I.PostageRuleID=P.PostageRuleID
	where SupplierID=1
	--and StatusID=1
) New on New.SKU=Old.SKU
left join 
(
	select M.OldSKU,I2.*,isnull(MaxPostage,0) as MaxPostage
	from Dropship.dbo.D_Item I2
	inner join AutoPostAdDealSplash.dbo.SKUMapping M on M.NewSKU=I2.SKU
	left join 
	(
		select 
		PostageRuleID,
		MAX(cast(Formula as decimal(18,2))) as MaxPostage
		from Dropship.dbo.T_PostageRuleLine
		group by PostageRuleID
	) P on I2.PostageRuleID=P.PostageRuleID
	where SupplierID=1
) M2 on M2.OldSKU=Old.SKU



--select export data

select
SKU,
InventoryQty,
--CEILING(((Price+case when Notes='FreeShipping' then 0 else Postage end)+0.3)/0.774)-0.05 as Price,
CEILING((Price+0.3)/0.774)-0.05 as Price,
--CEILING((Price+0.3)/0.904)-0.05 as Price,--(X-0.026x-0.3-Ds.Price)/x=0.07
Status,
Price as Cost,
case when Notes='FreeShipping' then 1 else 0 end as IsFreeShipping,
Postage
from AutoPostAdDropship.dbo.AutoPostAdPostData
where adtypeid=4

--update inventory

--1. Delete DropshipStockQty records
delete from DropshipStockQty

--2. Import records to DropshipStockQty from csv

--3. Update Qty
update P
set StockQuantity=UP.Qty,
Published=case when UP.Status=1 then 1 else 0 end,
Price=UP.Price+(case when UP.IsFreeShipping=1 then 0 else UP.Postage end),
ProductCost=UP.Cost+(case when UP.IsFreeShipping=1 then 0 else UP.Postage end),
IsFreeShipping=1,--UP.IsFreeShipping,
AdditionalShippingCharge=0--(case when UP.IsFreeShipping=1 then 0 else UP.Postage end)
from Product P
inner join
(

select
		NC.ID,
		NC.Sku,
		DS.Qty,
		NC.StockQuantity,
		DS.Status,
		DS.Price,
		DS.Cost,
		DS.IsFreeShipping,
		DS.Postage
		 from
		(
			select * from 
			DropshipStockQty
		) DS
		inner join
		(
			select * from Product
		) NC on DS.SKU=NC.SKU
) UP on P.ID=UP.ID

--4.Update sorting
update PCM
set DisplayOrder=1
from Product P
inner join Product_Category_Mapping PCM on P.Id=PCM.ProductId
where P.StockQuantity>0

update PCM
set DisplayOrder=999
from
Product P
inner join Product_Category_Mapping PCM on P.Id=PCM.ProductId
where P.StockQuantity<=0









--check potential customer
select * from customer
where createdonutc<>lastactivitydateutc


--hide product from being ordered

update Product
set VisibleIndividually=0
where Id>=55


--****************************************************************Add New Dropshipzone Products to NopCommerce Website**************************************************

--1. update category from dsz using dsz api with ebayService.GetCategories()

--2. insert new product from Dropship DB D_Item
insert into AutoPostAdDropship.dbo.AutoPostAdPostData
select 
New.SKU,
New.Price,
New.Title,
0 as CategoryID,
New.InventoryQty,
1 as AddressID,
1 as AccountID,
1 as CustomFieldGroupID,
'' as BusinessLogoPath,
New.Description,
'' as ImagesPath,
'' as CustomID,
New.StatusID as Status,
0 as Postage,
case when New.PostageRuleID=1 then 'FreeShipping' else '' end as Notes,-- will need to change postage rule ID
4 as AdTypeID,
1 as ScheduleRuleID
from 
(
select * from Dropship.dbo.D_Item
where SupplierID=1
) New 
left join 
(
select *
from AutoPostAdDropship.dbo.AutoPostAdPostData
where AdTypeID=4
) Old on New.SKU=Old.SKU
where Old.SKU is null
and New.SKU not like 'WP-%'
and New.SKU not like 'PH-%'
and New.SKU not like 'AZ-%'
and New.SKU not like 'AD-%'
and New.SKU not like 'KR-%'
and New.SKU not like 'VOF-%'
and New.SKU not like 'TRUG-%'
and New.SKU not like 'D8-%'
and New.SKU not like 'MAP-%'
and New.SKU not like 'V13-%'
and New.SKU not like 'V37-%'
and New.SKU not like 'V48-%'
and New.SKU not like 'V40-%'
and New.SKU not like 'V28-%'
and New.SKU not like 'V38-%'
and New.SKU not like 'V41-%'
and New.SKU not like 'V54-%'
and New.SKU not like 'V56-%'
and New.SKU not like 'V31-%'
and New.SKU not like 'V59-%'
and New.SKU not like 'V62-%'
and New.SKU not like 'V70-%'
and New.SKU not like 'V76-%'
and New.SKU not like 'V55-%'
and New.SKU not like 'V1-%'
and New.SKU not like 'V58-%'


--1. Fix product images for new products with ebayService.GetDropshipzoneProductImagesPath()
--2. update and add new categories
--		2.1 run AutoPostAd GetCategories
--		2.2 download and restore ozcrazymall db to local
--		2.3 insert new category to temp table
--		2.4 update new products categories from dsz using ebayService.UpdateDropshipzoneInfoForNopcommerce() (DSZ api permission required)

--insert nopcommerce level 1 category
select 
CategoryName as Name,
CategoryID as Description,
1 as CategoryTemplateId,
null as MetaKeywords,
null as MetaDescription,
null as MetaTitle,
0 as ParentCategoryId,
0 as PictureId,
20 as PageSize,
1 as AllowCustomersToSelectPageSize,
'20,40,60' as PageSizeOptions,
null as PriceRanges,
0 as ShowOnHomePage,
1 as IncludeInTopMenu,
0 as HasDiscountsApplied,
0 as SubjectToAcl,
0 as LimitedToStores,
1 as Published,
0 as Deleted,
row_number() over (order by categoryName) as DisplayOrder,
getdate() as CreatedOnUtc,
GETDATE() as UpdatedOnUtc

into TempInsertCategory
from AutoPostAdDropship.dbo.V_ProductCategory DSC 
left join ozcrazym_Nopcommerce.dbo.Category NOPC on DSC.CategoryID=NOPC.Description
where CategoryTypeID=4
and Status='A' 
and CategoryID<300
and CategoryLevel=3--category level 3 is the head category of dsz
and NOPC.Id is null


--Generate Scripts with temp table and save in a file

--insert category to nopcommerce db from temp table first

--delete temp table category
delete from TempInsertCategory















--insert nopcommerce level 2 category
--insert into TempInsertCategory
select 
CategoryName as Name,
CategoryID as Description,
1 as CategoryTemplateId,
NULL as MetaKeywords,
null as MetaDescription,
null as MetaTitle,
ISNULL(NC.Id,0) as ParentCategoryId,
0 as PictureId,
20 as PageSize,
1 as AllowCustomersToSelectPageSize,
'20,40,60' as PageSizeOptions,
null as PriceRanges,
0 as ShowOnHomePage,
1 as IncludeInTopMenu,
0 as HasDiscountsApplied,
0 as SubjectToAcl,
0 as LimitedToStores,
1 as Published,
0 as Deleted,
row_number() over (order by categoryName) as DisplayOrder,
getdate() as CreatedOnUtc,
GETDATE() as UpdatedOnUtc

--into TempInsertCategory
from AutoPostAdDropship.dbo.V_ProductCategory DC
left join ozcrazym_Nopcommerce.dbo.Category NC on DC.ParentCategoryID=ISNULL(NC.Description,0)
left join ozcrazym_Nopcommerce.dbo.Category NCC on DC.CategoryID=ISNULL(NCC.Description,0)
where CategoryTypeID=4
and Status='A' 
--and CategoryID<200
and CategoryLevel=4
and NCC.Id is null
and ISNULL(NC.Id,0)<>0










select 
Id as EntityId,
'Category' as EntityName,
REPLACE(REPLACE( REPLACE( LOWER(rtrim(ltrim(Name))),' & ','-'),' ','-'),',','') as Slug,
1 as IsActive,
0 as LanguageId
from ozcrazym_Nopcommerce.dbo.Category
where Deleted=0











--2.4 Generate Scripts and run it on production DB


--scripts:

INSERT [dbo].[Category] ([Name], [Description], [CategoryTemplateId], [MetaKeywords], [MetaDescription], [MetaTitle], [ParentCategoryId], [PictureId], [PageSize], [AllowCustomersToSelectPageSize], [PageSizeOptions], [PriceRanges], [ShowOnHomePage], [IncludeInTopMenu], [HasDiscountsApplied], [SubjectToAcl], [LimitedToStores], [Published], [Deleted], [DisplayOrder], [CreatedOnUtc], [UpdatedOnUtc]) VALUES (N'Christmas', N'192', 1, NULL, NULL, NULL, 0, 0, 20, 1, N'20,40,60', NULL, 0, 1, 0, 0, 0, 1, 0, 1, CAST(0x0000A54F0114CB33 AS DateTime), CAST(0x0000A54F0114CB33 AS DateTime))
GO






INSERT [dbo].[Category] ([Name], [Description], [CategoryTemplateId], [MetaKeywords], [MetaDescription], [MetaTitle], [ParentCategoryId], [PictureId], [PageSize], [AllowCustomersToSelectPageSize], [PageSizeOptions], [PriceRanges], [ShowOnHomePage], [IncludeInTopMenu], [HasDiscountsApplied], [SubjectToAcl], [LimitedToStores], [Published], [Deleted], [DisplayOrder], [CreatedOnUtc], [UpdatedOnUtc]) VALUES (N'Awning Cover', N'230', 1, NULL, NULL, NULL, 21, 0, 20, 1, N'20,40,60', NULL, 0, 1, 0, 0, 0, 1, 0, 1, CAST(0x0000A54F011654D9 AS DateTime), CAST(0x0000A54F011654D9 AS DateTime))
GO
INSERT [dbo].[Category] ([Name], [Description], [CategoryTemplateId], [MetaKeywords], [MetaDescription], [MetaTitle], [ParentCategoryId], [PictureId], [PageSize], [AllowCustomersToSelectPageSize], [PageSizeOptions], [PriceRanges], [ShowOnHomePage], [IncludeInTopMenu], [HasDiscountsApplied], [SubjectToAcl], [LimitedToStores], [Published], [Deleted], [DisplayOrder], [CreatedOnUtc], [UpdatedOnUtc]) VALUES (N'Breathalysers', N'232', 1, NULL, NULL, NULL, 20, 0, 20, 1, N'20,40,60', NULL, 0, 1, 0, 0, 0, 1, 0, 2, CAST(0x0000A54F011654D9 AS DateTime), CAST(0x0000A54F011654D9 AS DateTime))
GO
INSERT [dbo].[Category] ([Name], [Description], [CategoryTemplateId], [MetaKeywords], [MetaDescription], [MetaTitle], [ParentCategoryId], [PictureId], [PageSize], [AllowCustomersToSelectPageSize], [PageSizeOptions], [PriceRanges], [ShowOnHomePage], [IncludeInTopMenu], [HasDiscountsApplied], [SubjectToAcl], [LimitedToStores], [Published], [Deleted], [DisplayOrder], [CreatedOnUtc], [UpdatedOnUtc]) VALUES (N'Coat & Hat Racks', N'234', 1, NULL, NULL, NULL, 21, 0, 20, 1, N'20,40,60', NULL, 0, 1, 0, 0, 0, 1, 0, 3, CAST(0x0000A54F011654D9 AS DateTime), CAST(0x0000A54F011654D9 AS DateTime))
GO
INSERT [dbo].[Category] ([Name], [Description], [CategoryTemplateId], [MetaKeywords], [MetaDescription], [MetaTitle], [ParentCategoryId], [PictureId], [PageSize], [AllowCustomersToSelectPageSize], [PageSizeOptions], [PriceRanges], [ShowOnHomePage], [IncludeInTopMenu], [HasDiscountsApplied], [SubjectToAcl], [LimitedToStores], [Published], [Deleted], [DisplayOrder], [CreatedOnUtc], [UpdatedOnUtc]) VALUES (N'Cross Bar', N'201', 1, NULL, NULL, NULL, 15, 0, 20, 1, N'20,40,60', NULL, 0, 1, 0, 0, 0, 1, 0, 4, CAST(0x0000A54F011654D9 AS DateTime), CAST(0x0000A54F011654D9 AS DateTime))
GO
INSERT [dbo].[Category] ([Name], [Description], [CategoryTemplateId], [MetaKeywords], [MetaDescription], [MetaTitle], [ParentCategoryId], [PictureId], [PageSize], [AllowCustomersToSelectPageSize], [PageSizeOptions], [PriceRanges], [ShowOnHomePage], [IncludeInTopMenu], [HasDiscountsApplied], [SubjectToAcl], [LimitedToStores], [Published], [Deleted], [DisplayOrder], [CreatedOnUtc], [UpdatedOnUtc]) VALUES (N'Fitness Accessories', N'210', 1, NULL, NULL, NULL, 25, 0, 20, 1, N'20,40,60', NULL, 0, 1, 0, 0, 0, 1, 0, 5, CAST(0x0000A54F011654D9 AS DateTime), CAST(0x0000A54F011654D9 AS DateTime))
GO
INSERT [dbo].[Category] ([Name], [Description], [CategoryTemplateId], [MetaKeywords], [MetaDescription], [MetaTitle], [ParentCategoryId], [PictureId], [PageSize], [AllowCustomersToSelectPageSize], [PageSizeOptions], [PriceRanges], [ShowOnHomePage], [IncludeInTopMenu], [HasDiscountsApplied], [SubjectToAcl], [LimitedToStores], [Published], [Deleted], [DisplayOrder], [CreatedOnUtc], [UpdatedOnUtc]) VALUES (N'Fountains', N'237', 1, NULL, NULL, NULL, 18, 0, 20, 1, N'20,40,60', NULL, 0, 1, 0, 0, 0, 1, 0, 6, CAST(0x0000A54F011654D9 AS DateTime), CAST(0x0000A54F011654D9 AS DateTime))
GO
INSERT [dbo].[Category] ([Name], [Description], [CategoryTemplateId], [MetaKeywords], [MetaDescription], [MetaTitle], [ParentCategoryId], [PictureId], [PageSize], [AllowCustomersToSelectPageSize], [PageSizeOptions], [PriceRanges], [ShowOnHomePage], [IncludeInTopMenu], [HasDiscountsApplied], [SubjectToAcl], [LimitedToStores], [Published], [Deleted], [DisplayOrder], [CreatedOnUtc], [UpdatedOnUtc]) VALUES (N'Go Karts', N'233', 1, NULL, NULL, NULL, 16, 0, 20, 1, N'20,40,60', NULL, 0, 1, 0, 0, 0, 1, 0, 7, CAST(0x0000A54F011654D9 AS DateTime), CAST(0x0000A54F011654D9 AS DateTime))
GO
INSERT [dbo].[Category] ([Name], [Description], [CategoryTemplateId], [MetaKeywords], [MetaDescription], [MetaTitle], [ParentCategoryId], [PictureId], [PageSize], [AllowCustomersToSelectPageSize], [PageSizeOptions], [PriceRanges], [ShowOnHomePage], [IncludeInTopMenu], [HasDiscountsApplied], [SubjectToAcl], [LimitedToStores], [Published], [Deleted], [DisplayOrder], [CreatedOnUtc], [UpdatedOnUtc]) VALUES (N'Kitchen Bins', N'215', 1, NULL, NULL, NULL, 21, 0, 20, 1, N'20,40,60', NULL, 0, 1, 0, 0, 0, 1, 0, 8, CAST(0x0000A54F011654D9 AS DateTime), CAST(0x0000A54F011654D9 AS DateTime))
GO
INSERT [dbo].[Category] ([Name], [Description], [CategoryTemplateId], [MetaKeywords], [MetaDescription], [MetaTitle], [ParentCategoryId], [PictureId], [PageSize], [AllowCustomersToSelectPageSize], [PageSizeOptions], [PriceRanges], [ShowOnHomePage], [IncludeInTopMenu], [HasDiscountsApplied], [SubjectToAcl], [LimitedToStores], [Published], [Deleted], [DisplayOrder], [CreatedOnUtc], [UpdatedOnUtc]) VALUES (N'Lighting', N'190', 1, NULL, NULL, NULL, 21, 0, 20, 1, N'20,40,60', NULL, 0, 1, 0, 0, 0, 1, 0, 9, CAST(0x0000A54F011654D9 AS DateTime), CAST(0x0000A54F011654D9 AS DateTime))
GO
INSERT [dbo].[Category] ([Name], [Description], [CategoryTemplateId], [MetaKeywords], [MetaDescription], [MetaTitle], [ParentCategoryId], [PictureId], [PageSize], [AllowCustomersToSelectPageSize], [PageSizeOptions], [PriceRanges], [ShowOnHomePage], [IncludeInTopMenu], [HasDiscountsApplied], [SubjectToAcl], [LimitedToStores], [Published], [Deleted], [DisplayOrder], [CreatedOnUtc], [UpdatedOnUtc]) VALUES (N'Luggage Sets', N'213', 1, NULL, NULL, NULL, 19, 0, 20, 1, N'20,40,60', NULL, 0, 1, 0, 0, 0, 1, 0, 10, CAST(0x0000A54F011654D9 AS DateTime), CAST(0x0000A54F011654D9 AS DateTime))
GO
INSERT [dbo].[Category] ([Name], [Description], [CategoryTemplateId], [MetaKeywords], [MetaDescription], [MetaTitle], [ParentCategoryId], [PictureId], [PageSize], [AllowCustomersToSelectPageSize], [PageSizeOptions], [PriceRanges], [ShowOnHomePage], [IncludeInTopMenu], [HasDiscountsApplied], [SubjectToAcl], [LimitedToStores], [Published], [Deleted], [DisplayOrder], [CreatedOnUtc], [UpdatedOnUtc]) VALUES (N'Mannequin', N'231', 1, NULL, NULL, NULL, 19, 0, 20, 1, N'20,40,60', NULL, 0, 1, 0, 0, 0, 1, 0, 11, CAST(0x0000A54F011654D9 AS DateTime), CAST(0x0000A54F011654D9 AS DateTime))
GO
INSERT [dbo].[Category] ([Name], [Description], [CategoryTemplateId], [MetaKeywords], [MetaDescription], [MetaTitle], [ParentCategoryId], [PictureId], [PageSize], [AllowCustomersToSelectPageSize], [PageSizeOptions], [PriceRanges], [ShowOnHomePage], [IncludeInTopMenu], [HasDiscountsApplied], [SubjectToAcl], [LimitedToStores], [Published], [Deleted], [DisplayOrder], [CreatedOnUtc], [UpdatedOnUtc]) VALUES (N'Others', N'212', 1, NULL, NULL, NULL, 16, 0, 20, 1, N'20,40,60', NULL, 0, 1, 0, 0, 0, 1, 0, 12, CAST(0x0000A54F011654D9 AS DateTime), CAST(0x0000A54F011654D9 AS DateTime))
GO
INSERT [dbo].[Category] ([Name], [Description], [CategoryTemplateId], [MetaKeywords], [MetaDescription], [MetaTitle], [ParentCategoryId], [PictureId], [PageSize], [AllowCustomersToSelectPageSize], [PageSizeOptions], [PriceRanges], [ShowOnHomePage], [IncludeInTopMenu], [HasDiscountsApplied], [SubjectToAcl], [LimitedToStores], [Published], [Deleted], [DisplayOrder], [CreatedOnUtc], [UpdatedOnUtc]) VALUES (N'Speakers', N'211', 1, NULL, NULL, NULL, 14, 0, 20, 1, N'20,40,60', NULL, 0, 1, 0, 0, 0, 1, 0, 13, CAST(0x0000A54F011654D9 AS DateTime), CAST(0x0000A54F011654D9 AS DateTime))
GO
INSERT [dbo].[Category] ([Name], [Description], [CategoryTemplateId], [MetaKeywords], [MetaDescription], [MetaTitle], [ParentCategoryId], [PictureId], [PageSize], [AllowCustomersToSelectPageSize], [PageSizeOptions], [PriceRanges], [ShowOnHomePage], [IncludeInTopMenu], [HasDiscountsApplied], [SubjectToAcl], [LimitedToStores], [Published], [Deleted], [DisplayOrder], [CreatedOnUtc], [UpdatedOnUtc]) VALUES (N'Tools', N'238', 1, NULL, NULL, NULL, 15, 0, 20, 1, N'20,40,60', NULL, 0, 1, 0, 0, 0, 1, 0, 14, CAST(0x0000A54F011654D9 AS DateTime), CAST(0x0000A54F011654D9 AS DateTime))
GO
INSERT [dbo].[Category] ([Name], [Description], [CategoryTemplateId], [MetaKeywords], [MetaDescription], [MetaTitle], [ParentCategoryId], [PictureId], [PageSize], [AllowCustomersToSelectPageSize], [PageSizeOptions], [PriceRanges], [ShowOnHomePage], [IncludeInTopMenu], [HasDiscountsApplied], [SubjectToAcl], [LimitedToStores], [Published], [Deleted], [DisplayOrder], [CreatedOnUtc], [UpdatedOnUtc]) VALUES (N'Toys', N'118', 1, NULL, NULL, NULL, 16, 0, 20, 1, N'20,40,60', NULL, 0, 1, 0, 0, 0, 1, 0, 15, CAST(0x0000A54F011654D9 AS DateTime), CAST(0x0000A54F011654D9 AS DateTime))
GO
INSERT [dbo].[Category] ([Name], [Description], [CategoryTemplateId], [MetaKeywords], [MetaDescription], [MetaTitle], [ParentCategoryId], [PictureId], [PageSize], [AllowCustomersToSelectPageSize], [PageSizeOptions], [PriceRanges], [ShowOnHomePage], [IncludeInTopMenu], [HasDiscountsApplied], [SubjectToAcl], [LimitedToStores], [Published], [Deleted], [DisplayOrder], [CreatedOnUtc], [UpdatedOnUtc]) VALUES (N'Wedding Accessories', N'214', 1, NULL, NULL, NULL, 19, 0, 20, 1, N'20,40,60', NULL, 0, 1, 0, 0, 0, 1, 0, 16, CAST(0x0000A54F011654D9 AS DateTime), CAST(0x0000A54F011654D9 AS DateTime))
GO








--Run it on production DB

insert into ozcrazym_Nopcommerce.dbo.UrlRecord
select 
Id as EntityId,
'Category' as EntityName,
REPLACE(REPLACE( REPLACE( LOWER(rtrim(ltrim(Name))),' & ','-'),' ','-'),',','') as Slug,
1 as IsActive,
0 as LanguageId
from ozcrazym_Nopcommerce.dbo.Category
where Deleted=0
and Id>142




--3. Update Nopcommerce product
-- 3.1 Update dropshipzone data businesslogo(categories) using ebayService.UpdateDropshipzoneInfoForNopcommerce() !!!(refer to ebayService.FixDropshipzoneCategoryCustomID())!!!(when need to update all the product category, use FixDropshipzoneCategoryCustomID, when only need to update the added products' category, use UpdateDropshipzoneInfoForNopcommerce)
-- 3.2 Run AutoPostAd GenerateNopcommerceImportCSVFile(change [V_CustomAutoPostAdPostData] as "Add new product for oz crazy mall(nopcommerce)" section)
--	3.3 GenerateNopcommerceImportCSVFile will copy the images whose the product will be added, and upload the pictures to ozcrazymall ftp server
--	3.4 Import the files



























select *
from
(
	select * from AutoPostAdPostData
	where AdTypeID=4
) DS
left join
(
	select * from AutoPostAdPostData
	where AdTypeID=1
) GT on DS.SKU=GT.SKU
where GT.SKU is null






select GT.*,DS.*
from
(
	select * from AutoPostAdPostData
	where AdTypeID=4
) DS
left join
(
	select * from AutoPostAdPostData
	where AdTypeID=1
) GT on DS.SKU=GT.SKU
where GT.SKU is not null















--data feed for trading post

select 
Title,
CEILING((Price+0.3)/0.774)-0.05 as Price,
InventoryQty,
Description
from AutoPostAdDropship.dbo.AutoPostAdPostData
where AdTypeID=4
and status=1
and Notes='FreeShipping'







--insert missing level 1 category product mapping


insert into Product_Category_Mapping
select 
IP.Id as ProductId,
InsertMapping.ParentCategoryId as CategoryId,
0 as IsFeaturedProduct,
case when IP.StockQuantity>0 then 1 else 999 end as DisplayOrder
from Product IP
inner join 
(
	select distinct CH.* from
	(
	select 
	P.Id PId,
	C.Id CId,
	C.ParentCategoryId,
	P.Sku,
	C.Name,
	PC.Name as ParentCategoryName
	from Product P
	inner join Product_Category_Mapping PCM on P.Id=PCM.ProductId
	inner join Category C on PCM.CategoryId=C.Id
	inner join Category PC on C.ParentCategoryId=PC.Id
	where C.ParentCategoryId>0 
	and P.Published=1 and P.Deleted=0 and C.Published=1 and C.Deleted=0
	) CH
	left join
	(
	select 
	P.Id PId,
	C.Id CId,
	C.ParentCategoryId 
	from Product P
	inner join Product_Category_Mapping PCM on P.Id=PCM.ProductId
	inner join Category C on PCM.CategoryId=C.Id
	) PA on CH.PId=PA.PId and CH.ParentCategoryId=PA.CId
	where PA.PId is null
) InsertMapping on IP.Id=InsertMapping.PId




--Set the ssl back to false using sql
update setting
set Value='False'
where id=262


update Store
set SslEnabled=0
where Id=1



--Set the ssl back to true using sql
update setting
set Value='True'
where id=262


update Store
set SslEnabled=1
where Id=1


--Set new recaptcha private and public key
--Public key
update Setting
set Value='6LfOKDUUAAAAAIAMG2xCrUd_2d5CuzO9wFrirN53'
where Id=469

--Private key
update Setting
set Value='6LfOKDUUAAAAAGQvfDqa8RbYY-6t_VYiC4Kjo9sp'
where Id=470