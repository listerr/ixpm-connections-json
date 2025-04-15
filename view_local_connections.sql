-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.0.35 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.10.0.7004
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping structure for view ixpmanager.view_local_connections
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `view_local_connections` (
	`cust_id` INT NOT NULL,
	`abbreviatedName` VARCHAR(1) NULL COLLATE 'utf8mb3_unicode_ci',
	`autsys` INT NULL,
	`virt_id` INT NOT NULL,
	`trunk` TINYINT(1) NULL,
	`channelgroup` INT NULL,
	`lag_framing` TINYINT(1) NOT NULL,
	`fastlacp` TINYINT(1) NOT NULL,
	`ipv4_list` TEXT NULL COLLATE 'utf8mb3_unicode_ci',
	`ipv6_list` TEXT NULL COLLATE 'utf8mb3_unicode_ci',
	`vlan_list` TEXT NULL COLLATE 'utf8mb4_general_ci',
	`vlan_count` BIGINT NOT NULL,
	`port_type` INT NULL,
	`port_speed` INT NULL,
	`port_id_list` TEXT NULL COLLATE 'utf8mb4_general_ci',
	`fanout_physical_interface_id` INT NULL,
	`rate_limit` INT UNSIGNED NULL,
	`isRatelimit` BIGINT NULL,
	`port_status` INT NULL,
	`switch` VARCHAR(1) NULL COLLATE 'utf8mb3_unicode_ci',
	`switchport_list` TEXT NULL COLLATE 'utf8mb3_unicode_ci',
	`cabinet` VARCHAR(1) NULL COLLATE 'utf8mb3_unicode_ci',
	`loc_id` INT NOT NULL,
	`loc_name` VARCHAR(1) NULL COLLATE 'utf8mb3_unicode_ci',
	`loc_tag` VARCHAR(1) NULL COLLATE 'utf8mb3_unicode_ci',
	`ppp_circuit_ref` TEXT NULL COLLATE 'utf8mb3_unicode_ci',
	`ppp_id` TEXT NULL COLLATE 'utf8mb4_general_ci',
	`ppp_name` TEXT NULL COLLATE 'utf8mb3_unicode_ci',
	`ppp_connector_type` TEXT NULL COLLATE 'utf8mb4_general_ci',
	`vlaninterface_id_list` TEXT NULL COLLATE 'utf8mb4_general_ci',
	`rsclient` TINYINT(1) NULL,
	`ipv4enabled` TINYINT(1) NULL,
	`ipv4canping` TINYINT(1) NULL,
	`ipv4monitorrcbgp` TINYINT(1) NULL,
	`ipv6enabled` TINYINT(1) NULL,
	`ipv6canping` TINYINT(1) NULL,
	`ipv6monitorrcbgp` TINYINT(1) NULL,
	`name` VARCHAR(1) NULL COLLATE 'utf8mb3_unicode_ci',
	`shortname` VARCHAR(1) NULL COLLATE 'utf8mb3_unicode_ci',
	`cust_type` INT NULL,
	`cust_status` SMALLINT NULL,
	`isReseller` TINYINT(1) NOT NULL,
	`reseller` INT NULL,
	`isResold` INT NOT NULL,
	`mac_count` BIGINT NOT NULL,
	`mac_count_unique` BIGINT NOT NULL,
	`mac_list` TEXT NULL COLLATE 'utf8mb3_unicode_ci',
	`datejoin` DATE NULL,
	`corpwww` VARCHAR(1) NULL COLLATE 'utf8mb3_unicode_ci',
	`in_peeringdb` TINYINT(1) NOT NULL
) ENGINE=MyISAM;

-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `view_local_connections`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `view_local_connections` AS select `cust`.`id` AS `cust_id`,`cust`.`abbreviatedName` AS `abbreviatedName`,`cust`.`autsys` AS `autsys`,`virtualinterface`.`id` AS `virt_id`,`virtualinterface`.`trunk` AS `trunk`,`virtualinterface`.`channelgroup` AS `channelgroup`,`virtualinterface`.`lag_framing` AS `lag_framing`,`virtualinterface`.`fastlacp` AS `fastlacp`,group_concat(distinct `ipv4address`.`address` separator ',') AS `ipv4_list`,group_concat(distinct `ipv6address`.`address` separator ',') AS `ipv6_list`,group_concat(distinct `vlan`.`number` separator ',') AS `vlan_list`,count(distinct `vlan`.`number`) AS `vlan_count`,`switchport`.`type` AS `port_type`,max(`physicalinterface`.`speed`) AS `port_speed`,group_concat(distinct `physicalinterface`.`id` separator ',') AS `port_id_list`,max(`physicalinterface`.`fanout_physical_interface_id`) AS `fanout_physical_interface_id`,max(`physicalinterface`.`rate_limit`) AS `rate_limit`,max(if((`physicalinterface`.`rate_limit` > 0),1,0)) AS `isRatelimit`,`physicalinterface`.`status` AS `port_status`,`switch`.`name` AS `switch`,group_concat(distinct `switchport`.`name` separator ',') AS `switchport_list`,`cabinet`.`name` AS `cabinet`,`location`.`id` AS `loc_id`,`location`.`shortname` AS `loc_name`,`location`.`tag` AS `loc_tag`,group_concat(distinct `patch_panel_port`.`colo_circuit_ref` separator ',') AS `ppp_circuit_ref`,group_concat(distinct `patch_panel_port`.`id` separator ',') AS `ppp_id`,group_concat(distinct `patch_panel`.`name` separator ',') AS `ppp_name`,group_concat(distinct `patch_panel`.`connector_type` separator ',') AS `ppp_connector_type`,group_concat(distinct `vlaninterface`.`id` separator ',') AS `vlaninterface_id_list`,max(`vlaninterface`.`rsclient`) AS `rsclient`,max(`vlaninterface`.`ipv4enabled`) AS `ipv4enabled`,max(`vlaninterface`.`ipv4canping`) AS `ipv4canping`,max(`vlaninterface`.`ipv4monitorrcbgp`) AS `ipv4monitorrcbgp`,max(`vlaninterface`.`ipv6enabled`) AS `ipv6enabled`,max(`vlaninterface`.`ipv6canping`) AS `ipv6canping`,max(`vlaninterface`.`ipv6monitorrcbgp`) AS `ipv6monitorrcbgp`,`cust`.`name` AS `name`,`cust`.`shortname` AS `shortname`,`cust`.`type` AS `cust_type`,`cust`.`status` AS `cust_status`,`cust`.`isReseller` AS `isReseller`,`cust`.`reseller` AS `reseller`,if((`cust`.`reseller` > 0),1,0) AS `isResold`,count(`l2a`.`mac`) AS `mac_count`,count(distinct `l2a`.`mac`) AS `mac_count_unique`,group_concat(distinct `l2a`.`mac` separator ',') AS `mac_list`,`cust`.`datejoin` AS `datejoin`,`cust`.`corpwww` AS `corpwww`,`cust`.`in_peeringdb` AS `in_peeringdb` from (((((((((((((`cust` join `virtualinterface` on((`virtualinterface`.`custid` = `cust`.`id`))) join `physicalinterface` on((`physicalinterface`.`virtualinterfaceid` = `virtualinterface`.`id`))) join `vlaninterface` on((`vlaninterface`.`virtualinterfaceid` = `virtualinterface`.`id`))) left join `ipv4address` on((`vlaninterface`.`ipv4addressid` = `ipv4address`.`id`))) left join `ipv6address` on((`vlaninterface`.`ipv6addressid` = `ipv6address`.`id`))) join `switchport` on((`physicalinterface`.`switchportid` = `switchport`.`id`))) join `switch` on((`switchport`.`switchid` = `switch`.`id`))) join `vlan` on((`vlaninterface`.`vlanid` = `vlan`.`id`))) join `cabinet` on((`switch`.`cabinetid` = `cabinet`.`id`))) join `location` on((`cabinet`.`locationid` = `location`.`id`))) left join `patch_panel_port` on((`patch_panel_port`.`switch_port_id` = `switchport`.`id`))) left join `patch_panel` on(((`patch_panel`.`cabinet_id` = `cabinet`.`id`) and (`patch_panel_port`.`patch_panel_id` = `patch_panel`.`id`)))) left join `l2address` `l2a` on((`l2a`.`vlan_interface_id` = `vlaninterface`.`id`))) where ((`cust`.`dateleave` is null) or (`cust`.`dateleave` < '1970-01-01') or (`cust`.`dateleave` >= curdate())) group by `cust`.`id`,`cust`.`abbreviatedName`,`cust`.`autsys`,`virtualinterface`.`id`,`virtualinterface`.`trunk`,`virtualinterface`.`channelgroup`,`virtualinterface`.`lag_framing`,`virtualinterface`.`fastlacp`,`switchport`.`type`,`physicalinterface`.`status`,`switch`.`name`,`cabinet`.`name`,`location`.`id`,`location`.`shortname`,`location`.`tag`,`cust`.`name`,`cust`.`shortname`,`cust`.`type`,`cust`.`status`,`cust`.`isReseller`,`cust`.`reseller`,`cust`.`datejoin`,`cust`.`corpwww`,`cust`.`in_peeringdb`
;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
