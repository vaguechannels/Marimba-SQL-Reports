/*





*/



use invdb
Select "APPLICATION TITLE", [COMPLIANT], [NON-COMPLIANT],[NOT-CHECKEDIN] 
FROM (
SELECT 'Package/App/Deployment Name' AS "APPLICATION TITLE", 'COMPLIANT' "STATUS" , a.[id] as "ID" 
--SELECT distinct a.name, a.scantime -- USE IT TO FIND MACHINE NAMES(COMMENT ABOVE LINE)
FROM inv_compliance ic, inv_machine a WITH (NOLOCK) WHERE UPPER(ic.compliance_level) = 'COMPLIANT' 
AND UPPER(ic.type) = UPPER('Machine') AND UPPER(ic.policy_agent) = UPPER('MRBA Subscription Manager') 
AND ic.machine_id = a.id AND ic.url like '%CHANNEL URL' AND ic.policy_name like '%TARGET FQDN%'

UNION ALL

SELECT 'Package/App/Deployment Name' AS "APPLICATION TITLE" , 'NON-COMPLIANT' "STATUS" , a.[id] as "ID" 
--SELECT distinct a.name, a.scantime, ic.url, ic.policy_state, ic.endpoint_state -- USE IT TO FIND MACHINE NAMES(COMMENT ABOVE LINE)
FROM inv_compliance ic, inv_machine a WITH (NOLOCK) WHERE UPPER(ic.compliance_level) <> 'COMPLIANT' 
AND UPPER(ic.type) = UPPER('Machine') AND UPPER(ic.policy_agent) = UPPER('MRBA Subscription Manager') 
AND ic.machine_id = a.id AND ic.url like '%CHANNEL URL' AND ic.policy_name like '%TARGET FQDN%'

UNION ALL

SELECT 'Package/App/Deployment Name' AS "APPLICATION TITLE",  'NOT-CHECKEDIN' "STATUS", a.[id] as "ID" 
--SELECT distinct a.name, a.scantime -- USE IT TO FIND MACHINE NAMES(COMMENT ABOVE LINE)
from inv_subscription_policy isp, ldapsync_targets p, inv_machine a,
(select distinct cmt.machine_id from ldapsync_target_membership ctm, ldapsync_targets_machines cmt WITH (NOLOCK) where ctm.memberof_name like '%TARGET FQDN%' and ctm.target_id = cmt.target_id) macs 
where a.id = macs.machine_id and p.id = isp.target_id and p.target_name like '%TARGET FQDN%' and isp.url like  '%CHANNEL URL' 
and (not exists (select 1 from inv_machinecompliance mc where mc.url = isp.url and mc.policy_name = p.target_name and (mc.policy_state = isp.primary_state or mc.policy_state = isp.secondary_state) and macs.machine_id = mc.machine_id) )

) p PIVOT(COUNT ("ID") FOR "STATUS" IN ([COMPLIANT], [NON-COMPLIANT],[NOT-CHECKEDIN]))AS pvt
Order by "APPLICATION TITLE"
