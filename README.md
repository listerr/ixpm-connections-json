# JSON Connections Query for IXP Manager

## Purpose

* Get information about member connections
* Optional search query to select or exclude specific connection properties. ("List all connections" or "List all the connections matching specific criteria" or even: "Get me the connection info for this known ID/IP address/switch name+port name etc.")
* Returns a **flat** JSON data structure for ease of use i.e, making TSV or CSV type output or quick human-readable queries.
* Exposes fields which are not (yet) visible via the various the IXP Manager JSON templates.
* Hide the underlying database structure and *just get the data I want*.

I am hopeful this will be a feature in IXP Manager, or I'll learn enough php foo to write it as an extension.


## Use case

Setups between IXPs vary, however I designed this for the LONAP use case (and how we use the database) which is:

 * There is one main Peering VLAN which we care about (vlan 4) and this VLAN interface in IXP Manager is where the IP config etc reside.
 * Private and other VLANs don't have IP settings, or specific other settings like ipv4monitorrcbgp and so we don't need this.
 * We use the Patch Panels feature for cross connect IDs etc. (Although this will still work if you don't use Patch Panels)
 * Reseller ports can peer themselves in the peering VLAN, or have a dedicated "Reseller Uplink" port.
 * (If you don't do resellers, then the reseller fields won't be of interest.)


## MySQL View

  * There is a custom view in ixpmanager database `view_local_connections` which is a flat view of most of the useful fields properties of member connections.
  * Any field which is visible in this view will automatically be exposed in the JSON output.
  * MySQL does not have an explicit field type for boolean. Fields of type `TINYINT(1)` are assumed to be boolean `0/1` and are cast as JSON booleans `true` or `false`. (This seems to be the accepted behaviour in php/laravel and java etc.)
  * **Some fields are lists.** Multiple values are represented by comma-separated strings. This is to make it quick and simple to massage the JSON into flat formats like CSV/TSV etc and *not* present complex nested JSON structures containing nested lists and arrays. (Hard to flatten this into CSV/TSV etc, which always requires a fixed number of fields, even if those fields are empty.)
  * The order of such lists might be the same, but is not guaranteed. (This is due to the way MySQL selects them from the joined tables.)  

     For example, if there are multiple physical interfaces contained in a virtual interface, `switchport_list` and `ppp_circuit_ref` would contain comma separated lists of each value, but, you cannot safely assume items in the lists are in the same position relate to each other (i.e, the second port in `switchport_list` may not relate to the second circuit id in `ppp_circuit_ref`. ) If you need to be *sure*, then you probably *do* need a hierarchically structured JSON output.
  * The use case for this JSON output is **Get me all the things matching this criteria** (All VLANs for a port, all ports in a VLAN, all connections for member x, all connections matching x.) and not *Tell me specifically how these things relate to each other in the database*.


## JSON query for generating simple lists

The view is exposed in a flat JSON structure for simple lists:

  * https://yourhost/cgi-internal/json_connections
  
  (Recommended to host this on an internal server and not anything externally visible)
  
### Query Options

  * Parameters can be added to the URL to select various attributes (multiple options will be ANDed together):
  * https://yourhost/cgi-internal/json_connections?loc_name=THW&port_speed=10000

|  Option                        | Example                               |
|--------------------------------|---------------------------------------|
| Select multiple values         |  `field=value1,value2,value3`         |
| Select **all** values (for fields that have a default set e.g. `cust_status` or `vlan`)  | `field=all` |
| Exclude (NOT) values           | `^field=value`                         |
| Search for *value* anywhere in text (by default, only exact matches are found) | `field=_value`           |
| Sort order                     | `order_by=field` (**default**: `abbreviatedName`)                        |
| Select fields for output.  Other fields are omitted. (Must match the name in the JSON output).  Useful for removing the clutter from JSON output to show only fields you are interested in. (Fields not shown may still be used to search.)  | `select=field1,field2,field3`  |
| Boolean values. Booleans are represented in the database as `1` or `0` `TINYINT(1)`, but `0` can also mean "undefined". To match booleans correctly, use `true` or `false`.                                                                                                          | `field=true`,  `field=false`,   |

### Defaults

 * This is what we usually want, unless I say otherwise...

 * To avoid specific use cases or business logic being hard-coded into the view, the query can return everything
   rather than hard-coded arbitrary "always exclude reseller uplink ports" or "only include connected ports"
   
 * That said, the following defaults are set, but can be changed either permanently in the script, 
   or overidden in the query.
    
 * Some fields have (hopefully useful) defaults are used if they are not explicitly specified (or you don't do `field=all`)
 
 * This makes it friendly for casual "human use", changing the defaults may affect scripts, so it probably 
   makes sense to always explicitly state what you want when using in scripts.
   
 * Modify these defaults in `%defs` to suit.
 

| Field               | Default                                             | Query                   |
| --------------------|-----------------------------------------------------|-------------------------|
|  `vlan_list`        | vlan 4 (peering VLAN) is in list                    | `vlan=4`                |  
|  `cust_type`        | Excludes 3 (internal)                               | `^cust_type=3`          |
|  `cust_status`      | 1 (normal)                                          | `cust_status=1`         |
|  `port_status`      | 1 (connected)                                       | `port_status=1`         |
|                     |                                                     |                         |
|  `ppp_circuit_ref`  | Anywhere in text                                    | `ppp_circuit_ref=_(value)`| 


### General Fields

| Field               | Description                                                                                            |
| --------------------|--------------------------------------------------------------------------------------------------------|
| `cabinet`           | Cabinet name (example: `inx-1`)                                                                        |
| `channelgroup`      | Port channel group number (example: `103`)                                                             |
| `cust_status`       | Cust status 1=normal, 2=not connected, 3=suspended  (**default**: 1)                                   |
| `cust_type`         | Cust type 1=full, 3=internal, 4=probono  (**default**: ! = 3)                                          |
| `fanout_physical_interface_id`  | For resold ports, the `port_id` of the associated reseller fanout port                     |
| `fastlacp   `       | (Bool) is Fast LACP mode enabled? (`true/false`)                                                       |
| `ipv4canping`       | (Bool) IPv4 monitoring/ping enabled?  (`true/false`)                                                   |
| `ipv4enabled`       | (Bool) Is IPv4 enabled?  (`true/false`)  Note: `true` if `ipv4enabled` on **any** VLAN interface       |
| `ipv4monitorrcbgp`  | (Bool) Is IPv4 Collector session monitoring enabled? (`true/false`)                                    |
| `ipv6canping`       | (Bool) IPv6 monitoring/ping enabled?  (`true/false`)                                                   |
| `ipv6enabled`       | (Bool) Is IPv6 enabled? (example: `true`)  Note: `true` if `ipv6enabled` on **any** VLAN interface     |
| `ipv6monitorrcbgp`  | (Bool) IPv6 monitoring/ping enabled?  (`true/false`)                                                   |
| `isRatelimit`       | (Bool) Is rate limited?  (`true/false`) (true if `rate_limit> 0`)                                      |
| `isReseller`        | (Bool) is a Reseller (`true/false`)                                                                    |
| `isResold`          | (Bool) is a resold member  (`true` if `reseller > 0`)                                                  |
| `lag_framing `      | (Bool) is LACP enabled? (`true/false`)                                                                 |
| `loc_id`            | Location ID in IXPM e.g `3`                                                                            |
| `loc_name`          | Location name (example: `HEX`)                                                                         |
| `mac_count`         | Number of MAC addresses in IXPM across all vlan interfaces                                             |
| `mac_count_unique`  | Number of Unique MAC addresses in IXPM across all vlan interfaces                                      |
| `mac_list`          | List of Unique MAC addresses in IXPM across all vlan interfaces                                        |
| `port_speed`        | Port speed (example: `1000`)                                                                           |
| `port_status `      | Port status 1=connected, 2=disabled, 3=not connected, 4=awaiting x-connect, 5=quarantine (default: 1)  |
| `port_type `        | Port type  (**default**: 1) 1=peering, 2=monitor, 3=core, 4=other, 5=mgmt, 6=fanout, 7=reseller        |
| `ppp_name`          | Patch panel name  (all ports on a given panel) (example: `THE:TFM40:F11:P01/C`)                        |
| `rate_limit`        | Port rate limit (example: `1000`)                                                                      |
| `reseller`          | ID of resold member's reseller                                                                         |
| `rsclient`          | (Bool) Is Route server client enabled? (`true/false`)                                                  |
| `switchport_list`    | Switchport name(s) (example: `Ethernet18/1`) Useful in combination with `switch`                      |
| `switch`            | Switch name                                                                                            |
| `trunk`             | (Bool) is trunk (802.1q tagging) enabled? (`true/false`)                                               |
| `vlan_count`        | Number of VLANs on port                                                                                |
| `vlan_list`         | VLAN **tag** id to select. (**default**: 4)                                                            |


### Member / Port Specific Fields ###

These are not so useful for lists but might be useful for querying ports for a given member.

| Field              | Description                                                |
|--------------------|------------------------------------------------------------|
| `cust_id`          | cust_id in IXPM database                                   |
| `autsys`           | ASN. Will return **all** cust type/status and port status  |
| `shortname`        | shortname in IXPM database                                 |
| `abbreviatedName`  | abbreviatedName  in IXPM database                         |
| `virt_id`          | Ports belonging to virtual interface id in IXPM           |
| `ppp_circuit_ref ` | patch panel circuit ref (example: `TIC-027774 6/8`)       |
| `ppp_id`           | patch panel port ID in IXPM                               |
| `ipv4 `            | ipv4 address                                              |
| `ipv4 `            | ipv6 address                                              |


#### Example output
 
```javascript
   {
      "abbreviatedName" : "Foonet",
      "autsys" : 65535,
      "cabinet" : "eqs-1",
      "channelgroup" : 102,
      "cust_id" : 13,
      "cust_status" : 1,
      "cust_type" : 1,
      "fanout_physical_interface_id" : null,
      "fastlacp" : false,
      "ipv4_list" : "5.57.80.250",
      "ipv4canping" : true,
      "ipv4enabled" : true,
      "ipv4monitorrcbgp" : true,
      "ipv6_list" : "2001:7f8:17::aaaa:1",
      "ipv6canping" : true,
      "ipv6enabled" : true,
      "ipv6monitorrcbgp" : true,
      "isRatelimit" : false,
      "isReseller" : false,
      "isResold" : false,
      "lag_framing" : true,
      "loc_id" : 7,
      "loc_name" : "LD6",
      "mac_count" : 2,
      "mac_count_unique" : 1,
      "mac_list" : "68215f83e073",
      "name" : "Foo Networks Ltd.",
      "port_id_list" : "869,878",
      "port_speed" : 100000,
      "port_status" : 1,
      "port_type" : 1,
      "ppp_circuit_ref" : "20457771,21450741",
      "ppp_id" : "265,277",
      "ppp_name" : "CP0403:1070390",
      "rate_limit" : null,
      "reseller" : null,
      "rsclient" : true,
      "shortname" : "foonet",
      "switch" : "eqs-cr1",
      "switchport_list" : "Ethernet7/1,Ethernet8/1",
      "trunk" : false,
      "virt_id" : 90,
      "vlan_count" : 1,
      "vlan_list" : "4"
   },
[...]   
]
}
```

### Examples: 

 Use `curl` if you like. For manual things I like to use `wget` but they basically do the same thing.

#### Get all live 1G ports in site THE, I want abbreviatedName, autsys, ipv4 and ipv6 in the output: ###

  * Using with `jq` to get a tab-separated list of the fields you want for a maintenance announcement

```bash
$ wget -qO - 'https://yourhost/cgi-internal/json_connections?loc_name=THE&port_speed=1000' | jq -r '.connections[] | [.abbreviatedName,.autsys,.ipv4_list,.ipv6_list] | @tsv'
teleBIZZ        41103   5.57.80.182     2001:7f8:17::a08f:1
Fastnet International   12519   5.57.80.121     2001:7f8:17::30e7:2
[...]
```

#### Get all live ports on switch eqs-qr1, I want name, autsys, ipv4 and ipv6: ###

```bash
$ wget -qO - 'https://yourhost/cgi-internal/json_connections?switch=eqs-qr1' | jq -r '.connections[] | [.abbreviatedName,.autsys,.ipv4_list,.ipv6_list] | @tsv'
Daisy Corporate 5413    5.57.80.15      2001:7f8:17::1525:2
AXA Insurance UK        34746   5.57.80.179
Gamma Telecom   31655   5.57.80.177     2001:7f8:17::7ba7:2
Nominet 8683    5.57.80.52      2001:7f8:17::21eb:1
Cisco OpenDNS   36692   5.57.80.198     2001:7f8:17::8f54:1
Olivenet        201746  5.57.82.68      2001:7f8:17::3:1412:1
[...]
```

#### All RS clients in all racks in site THN  ###

```
https://yourhost/cgi-internal/json_connections?loc_name=THN&rsclient=true
```

#### All connections that are NOT RS clients ###
```
https://yourhost/cgi-internal/json_connections?rsclient=false
```

#### All Fanout ports for all resellers ###

  * Show only fields: `abbreviatedName,autsys,ipv4_list,ipv6_list,isReseller,switch,switchport_list,port_type,vlan_list`

```
https://yourhost/cgi-internal/json_connections?vlan=all&isReseller=true&port_type=6&select=abbreviatedName,autsys,ipv4_list,ipv6_list,isReseller,switch,switchport_list,port_type,vlan_list
```

### ASNs of all RS clients with ipv6 enabled  ###

```bash
$ wget -qO - 'https://yourhost/cgi-internal/json_connections?rsclient=1&ipv6enabled=1&order_by=autsys' | jq -r '.connections[] | [.autsys] | @tsv' | uniq
42
1820
2603
2818
2906
3213
3856
4455
5463
[...lots...]
211371
211597
212109
212655
212880
396998
```

### Limit JSON output to a given list of fields ###

  * Add `select=` to specify a list of fields to include in the JSON output, instead of all fields.

`https://yourhost/cgi-internal/json_connections?switch=inx-sr1&select=abbreviatedName,autsys,ipv4_list,ipv6_list,switch,switchport_list,port_speed,rate_limit`

```javascript
{
"connections": [
   {
      "abbreviatedName" : "Member",
      "autsys" : 12345,
      "ipv4_list" : "5.57.80.250",
      "ipv6_list" : "2001:7f8:17::aaaa:1",
      "port_speed" : 10000,
      "rate_limit" : 1000,
      "switch" : "inx-sr1",
      "switchport_list" : "Ethernet21"
   },
...
]
}

```

## TODO

 * Select where value is not null
 * Wrapper for error return msg to json (correct return codes) and for "an error occurred" "field not found" or "query ran okay but no results found."
 * Optional structures for use with automation (flat output can only go so far...)
   * Example: auto_neg and duplex settings where you _do_ actually need to know the value for each physical interface, not an aggregate of all interfaces.
 * Authentication
 * Move database functions to module + config file
 * Learn some php foo
 * Do this again in more "modern" framework
