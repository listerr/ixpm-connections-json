## Human readable query from view_local_connections

```sql
SELECT
    cust.id AS cust_id,
    cust.abbreviatedName,
    cust.autsys,
    virtualinterface.id AS virt_id,
    virtualinterface.trunk,
    virtualinterface.channelgroup,
    virtualinterface.lag_framing,
    virtualinterface.fastlacp,
    Group_Concat(DISTINCT ipv4address.address) AS ipv4_list,
    Group_Concat(DISTINCT ipv6address.address) AS ipv6_list,
    Group_Concat(DISTINCT vlan.number) AS vlan_list,
    Count(DISTINCT vlan.number) AS vlan_count,
    switchport.type AS port_type,
    Max(physicalinterface.speed) AS port_speed,
    Group_Concat(DISTINCT physicalinterface.id) AS port_id_list,
    Max(physicalinterface.fanout_physical_interface_id) AS fanout_physical_interface_id,
    Max(physicalinterface.rate_limit) AS rate_limit,
    Max(If(physicalinterface.rate_limit > 0, 1, 0)) AS isRatelimit,
    physicalinterface.status AS port_status,
    switch.name AS switch,
    Group_Concat(DISTINCT switchport.name) AS switchport_list,
    cabinet.name AS cabinet,
    location.id AS loc_id,
    location.shortname AS loc_name,
    location.tag AS loc_tag,
    Group_Concat(DISTINCT patch_panel_port.colo_circuit_ref) AS ppp_circuit_ref,
    Group_Concat(DISTINCT patch_panel_port.id) AS ppp_id,
    Group_Concat(DISTINCT patch_panel.name) AS ppp_name,
    Group_Concat(DISTINCT patch_panel.connector_type) AS ppp_connector_type,
    Group_Concat(DISTINCT vlaninterface.id) AS vlaninterface_id_list,
    Max(DISTINCT vlaninterface.rsclient) AS rsclient,
    Max(DISTINCT vlaninterface.ipv4enabled) AS ipv4enabled,
    Max(DISTINCT vlaninterface.ipv4canping) AS ipv4canping,
    Max(DISTINCT vlaninterface.ipv4monitorrcbgp) AS ipv4monitorrcbgp,
    Max(DISTINCT vlaninterface.ipv6enabled) AS ipv6enabled,
    Max(DISTINCT vlaninterface.ipv6canping) AS ipv6canping,
    Max(DISTINCT vlaninterface.ipv6monitorrcbgp) AS ipv6monitorrcbgp,
    cust.name,
    cust.shortname,
    cust.type AS cust_type,
    cust.status AS cust_status,
    cust.isReseller,
    cust.reseller,
    If(cust.reseller > 0, 1, 0) AS isResold,
    Count(l2a.mac) AS mac_count,
    Count(DISTINCT l2a.mac) AS mac_count_unique,
    Group_Concat(DISTINCT l2a.mac) AS mac_list,
    cust.datejoin,
    cust.corpwww,
    cust.in_peeringdb
FROM
    cust
    INNER JOIN virtualinterface ON virtualinterface.custid = cust.id
    INNER JOIN physicalinterface ON physicalinterface.virtualinterfaceid = virtualinterface.id
    INNER JOIN vlaninterface ON vlaninterface.virtualinterfaceid = virtualinterface.id
    LEFT OUTER JOIN ipv4address ON vlaninterface.ipv4addressid = ipv4address.id
    LEFT OUTER JOIN ipv6address ON vlaninterface.ipv6addressid = ipv6address.id
    INNER JOIN switchport ON physicalinterface.switchportid = switchport.id
    INNER JOIN switch ON switchport.switchid = switch.id
    INNER JOIN vlan ON vlaninterface.vlanid = vlan.id
    INNER JOIN cabinet ON switch.cabinetid = cabinet.id
    INNER JOIN location ON cabinet.locationid = location.id
    LEFT OUTER JOIN patch_panel_port ON patch_panel_port.switch_port_id = switchport.id
    LEFT OUTER JOIN patch_panel ON patch_panel.cabinet_id = cabinet.id AND
            patch_panel_port.patch_panel_id = patch_panel.id
    LEFT OUTER JOIN l2address l2a ON l2a.vlan_interface_id = vlaninterface.id
WHERE
    (isnull(cust.dateleave) OR
        (cust.dateleave < '1970-01-01') OR
        (cust.dateleave >= CurDate()))
GROUP BY
    cust.id,
    cust.abbreviatedName,
    cust.autsys,
    virtualinterface.id,
    virtualinterface.trunk,
    virtualinterface.channelgroup,
    virtualinterface.lag_framing,
    virtualinterface.fastlacp,
    switchport.type,
    physicalinterface.status,
    switch.name,
    cabinet.name,
    location.id,
    location.shortname,
    location.tag,
    cust.name,
    cust.shortname,
    cust.type,
    cust.status,
    cust.isReseller,
    cust.reseller,
    cust.datejoin,
    cust.corpwww,
    cust.in_peeringdb
```

