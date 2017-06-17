


use invdb
Select "Marimba Patch Group", [COMPLIANT], [NON-COMPLIANT],[NON-CHECKEDIN] 
FROM (

SELECT distinct SUBSTRING(ic.url, LEN(RIGHT(ic.url, CHARINDEX ('/C', ic.url))) + 1, LEN(ic.url) - LEN(LEFT(ic.url, CHARINDEX ('/', ic.url))) ) AS "Marimba Patch Group" , 'COMPLIANT' "STATUS" , a.[id] as "ID"
FROM inv_compliance ic, inv_machine a 
WHERE ic.compliance_level = 'COMPLIANT' AND ic.type = 'Machine' AND ic.policy_agent = 'MRBA Subscription Manager' AND ic.machine_id = a.id 
AND (ic.url like '%/PatchManagement/PatchGroups/Cumulative%' or ic.url like '%/PatchManagement/PatchGroups/%2017%' or ic.url like '%/PatchManagement/PatchGroups/%WannaCrypt%' )
AND ( ic.policy_name like 'ou=workstations,dc=dcsg,dc=com' or ic.policy_name like 'ou=clients,dc=dcsg,dc=com')

UNION ALL

SELECT distinct SUBSTRING(ic.url, LEN(RIGHT(ic.url, CHARINDEX ('/C', ic.url))) + 1, LEN(ic.url) - LEN(LEFT(ic.url, CHARINDEX ('/', ic.url))) ) AS "Marimba Patch Group" , 'NON-COMPLIANT' "STATUS" , a.[id] as "ID"
FROM inv_compliance ic, inv_machine a 
WHERE ic.compliance_level <> 'COMPLIANT' AND ic.type = 'Machine' AND ic.policy_agent = 'MRBA Subscription Manager' AND ic.machine_id = a.id 
AND (ic.url like '%/PatchManagement/PatchGroups/Cumulative%' or ic.url like '%/PatchManagement/PatchGroups/%2017%' or ic.url like '%/PatchManagement/PatchGroups/%WannaCrypt%' )
AND ( ic.policy_name like 'ou=workstations,dc=dcsg,dc=com' or ic.policy_name like 'ou=clients,dc=dcsg,dc=com')

UNION ALL

SELECT distinct SUBSTRING(isp.url, LEN(RIGHT(isp.url, CHARINDEX ('/C', isp.url))) + 1, LEN(isp.url) - LEN(LEFT(isp.url, CHARINDEX ('/', isp.url))) ) AS "Marimba Patch Group",  'NON-CHECKEDIN' "STATUS", a.[id] as "ID"
from inv_machine a ,ldapsync_target_membership tme, inv_subscription_policy isp, ldapsync_targets_machines tma
where (isp.url like '%/PatchManagement/PatchGroups/Cumulative%' or isp.url like '%/PatchManagement/PatchGroups/%2017%' or isp.url like '%/PatchManagement/PatchGroups/%WannaCrypt%' )
and a.id = tma.machine_id and tma.target_id=tme.target_id and tme.memberof_target_id=isp.target_id 
and not exists (select 1 from inv_machinecompliance mc where mc.machine_id =a.id and mc.url=isp.url)
) p
PIVOT
(COUNT ("ID")
FOR "STATUS" IN ([COMPLIANT], [NON-COMPLIANT],[NON-CHECKEDIN]))AS pvt
Order by "Marimba Patch Group"
