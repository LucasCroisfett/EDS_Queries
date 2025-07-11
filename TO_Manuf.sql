%sql
with 
A ( -- Base with all the Actions (Terminations) 
  select 
    inout.`Org Lv N-3 Code`,
    inout.`Org Lv N-3 Desc`,
    UPPER(inout.`GeoCity.Employee`) as City,
    inout.`Period`,
    CONCAT(inout.`Org Lv N-3 Code`,City,inout.`Period`) as KeyConnection,
    SUM(CASE WHEN inout.`Action_Reason` LIKE '%voluntary%' THEN 1 ELSE 0 END) as TO_Voluntary,
    COUNT(inout.`Action_Reason`) as TO_Total
  from silver_hrsi_sandbox.global_reporting.ytd_in_out_new inout
  where 1=1 
    and inout.Position_Type = 'Primary'
    and inout.IN_OUT = 'OUT'
    and inout.`Permanent/Temporary` = 'Permanent'
    and inout.`Employee_Class` IN ('Regular', 'Temporary Assignment')
    and inout.`Org Lv N-3 Code` IN 
                                  ('50018374','11200227','10800153','10600988','10600986','11500276','50049973','11500279','14600355','10300093','11200228','14000057','50063634','11500282','11500283','11500284','11050477','11050478','11050479','11050541','11050542','11050481','11050482','50037486')
  group by 
  `Org Lv N-3 Code`,
  `Org Lv N-3 Desc`,
  City,
  `Period`
),

B ( -- Base with all the Basic Info (Headcount)
  select
    inout.Org_Lv3_Code,
    inout.Org_Lv3,
    inout.City_Employee as City,
    inout.`Period`,
    concat(inout.Org_Lv3_Code,City,inout.`Period`) as KeyConnection,
    count(inout.Personnel_Number) as HC_Count
  from silver_hrsi_sandbox.master_tables.master_consolidation inout
  where 1=1 
    and inout.Position_Type = 'Primary'
  group by
    Org_Lv3_Code,
    Org_Lv3,
    City,
    `Period`
)

select 
A.*,
B.HC_Count

from A
left join B
on A.KeyConnection = B.KeyConnection