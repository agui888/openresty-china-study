/*
Navicat MySQL Data Transfer

Source Server         : 192.168.137.111
Source Server Version : 50531
Source Host           : 192.168.137.111:3306
Source Database       : orange

Target Server Type    : MYSQL
Target Server Version : 50531
File Encoding         : 65001

Date: 2016-12-08 11:04:10
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `basic_auth`
-- ----------------------------
DROP TABLE IF EXISTS `basic_auth`;
CREATE TABLE `basic_auth` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL DEFAULT '',
  `value` varchar(2000) NOT NULL DEFAULT '',
  `op_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_basic_auth_key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of basic_auth
-- ----------------------------
INSERT INTO `basic_auth` VALUES ('1', 'c61651a6-f69c-4cff-825e-2b58c17115b4', '{\"enable\":true,\"handle\":{\"log\":false,\"credentials\":[{\"password\":\"orange_admin\",\"username\":\"admin\"}],\"code\":401},\"time\":\"2016-11-08 16:30:25\",\"judge\":{\"type\":0,\"conditions\":[{\"type\":\"URI\",\"operator\":\"match\",\"value\":\"admin\"}]},\"name\":\"admin\",\"id\":\"c61651a6-f69c-4cff-825e-2b58c17115b4\"}', '2016-11-08 16:30:25');

-- ----------------------------
-- Table structure for `dashboard_user`
-- ----------------------------
DROP TABLE IF EXISTS `dashboard_user`;
CREATE TABLE `dashboard_user` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(60) NOT NULL DEFAULT '' COMMENT '用户名',
  `password` varchar(255) NOT NULL DEFAULT '' COMMENT '密码',
  `is_admin` tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否是管理员账户：0否，1是',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建或者更新时间',
  `enable` tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否启用该用户：0否1是',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COMMENT='dashboard users';

-- ----------------------------
-- Records of dashboard_user
-- ----------------------------
INSERT INTO `dashboard_user` VALUES ('1', 'admin', '6d07c68fad31cf4c5aadc2b87d1bc4fc87cd16f6d0298d138ad3c08355d00e74', '1', '2016-11-08 16:33:25', '1');
INSERT INTO `dashboard_user` VALUES ('2', 'test', '6d07c68fad31cf4c5aadc2b87d1bc4fc87cd16f6d0298d138ad3c08355d00e74', '0', '2016-11-08 16:31:22', '1');
INSERT INTO `dashboard_user` VALUES ('3', 'luoyuxiang', '6d07c68fad31cf4c5aadc2b87d1bc4fc87cd16f6d0298d138ad3c08355d00e74', '0', '2016-11-08 16:31:51', '1');

-- ----------------------------
-- Table structure for `divide`
-- ----------------------------
DROP TABLE IF EXISTS `divide`;
CREATE TABLE `divide` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL DEFAULT '',
  `value` varchar(2000) NOT NULL DEFAULT '',
  `op_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_divide_key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of divide
-- ----------------------------
INSERT INTO `divide` VALUES ('1', '7d2ac910-b82f-4ce7-bf3e-93b30368275d', '{\"upstream_url\":\"http:\\/\\/www.subpub.cn:8002\",\"judge\":{\"type\":0,\"conditions\":[{\"type\":\"URI\",\"operator\":\"match\",\"value\":\"1000\"}]},\"enable\":true,\"id\":\"7d2ac910-b82f-4ce7-bf3e-93b30368275d\",\"log\":true,\"upstream_host\":\"www.subpub.cn:80\",\"name\":\"1000\",\"extractor\":{\"type\":1,\"extractions\":{}}}', '2016-11-08 16:27:06');

-- ----------------------------
-- Table structure for `key_auth`
-- ----------------------------
DROP TABLE IF EXISTS `key_auth`;
CREATE TABLE `key_auth` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL DEFAULT '',
  `value` varchar(2000) NOT NULL DEFAULT '',
  `op_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_key_auth_key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of key_auth
-- ----------------------------
INSERT INTO `key_auth` VALUES ('1', '20c96532-0fad-4e26-a6cd-7adc4213cb06', '{\"enable\":true,\"handle\":{\"log\":false,\"credentials\":[{\"type\":1,\"target_value\":\"valuez\",\"key\":\"keyz\"}],\"code\":401},\"time\":\"2016-11-08 16:32:41\",\"judge\":{\"type\":0,\"conditions\":[{\"type\":\"URI\",\"operator\":\"match\",\"value\":\"luoyuxiang\"}]},\"name\":\"luoyuxiang\",\"id\":\"20c96532-0fad-4e26-a6cd-7adc4213cb06\"}', '2016-11-08 16:32:41');

-- ----------------------------
-- Table structure for `meta`
-- ----------------------------
DROP TABLE IF EXISTS `meta`;
CREATE TABLE `meta` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL DEFAULT '',
  `value` varchar(5000) NOT NULL DEFAULT '',
  `op_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of meta
-- ----------------------------
INSERT INTO `meta` VALUES ('1', 'redirect.enable', '1', '2016-10-31 23:30:13');
INSERT INTO `meta` VALUES ('2', 'waf.enable', '1', '2016-10-31 23:31:42');
INSERT INTO `meta` VALUES ('3', 'divide.enable', '1', '2016-10-31 23:31:51');
INSERT INTO `meta` VALUES ('4', 'key_auth.enable', '1', '2016-10-31 23:32:13');
INSERT INTO `meta` VALUES ('6', 'monitor.enable', '1', '2016-10-31 23:32:27');
INSERT INTO `meta` VALUES ('8', 'basic_auth.enable', '1', '2016-11-08 15:38:16');
INSERT INTO `meta` VALUES ('9', 'rewrite.enable', '1', '2016-11-08 16:11:14');

-- ----------------------------
-- Table structure for `monitor`
-- ----------------------------
DROP TABLE IF EXISTS `monitor`;
CREATE TABLE `monitor` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL DEFAULT '',
  `value` varchar(2000) NOT NULL DEFAULT '',
  `op_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_key` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of monitor
-- ----------------------------

-- ----------------------------
-- Table structure for `redirect`
-- ----------------------------
DROP TABLE IF EXISTS `redirect`;
CREATE TABLE `redirect` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL DEFAULT '',
  `value` varchar(2000) NOT NULL DEFAULT '',
  `op_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of redirect
-- ----------------------------
INSERT INTO `redirect` VALUES ('1', '92836555-6c88-4952-ae90-afbc2c7792f2', '{\"enable\":true,\"handle\":{\"trim_qs\":false,\"url_tmpl\":\"\\/test\\/test\",\"log\":true},\"id\":\"92836555-6c88-4952-ae90-afbc2c7792f2\",\"judge\":{\"type\":0,\"conditions\":[{\"type\":\"URI\",\"operator\":\"match\",\"value\":\"test\"}]},\"name\":\"test\",\"extractor\":{\"type\":1,\"extractions\":{}}}', '2016-11-08 16:17:21');

-- ----------------------------
-- Table structure for `rewrite`
-- ----------------------------
DROP TABLE IF EXISTS `rewrite`;
CREATE TABLE `rewrite` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL DEFAULT '',
  `value` varchar(2000) NOT NULL DEFAULT '',
  `op_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of rewrite
-- ----------------------------
INSERT INTO `rewrite` VALUES ('1', 'e663e129-c768-4a8a-ba7d-5cf66455cb68', '{\"enable\":true,\"handle\":{\"log\":true,\"uri_tmpl\":\"\\/robots.txt\"},\"id\":\"e663e129-c768-4a8a-ba7d-5cf66455cb68\",\"judge\":{\"type\":0,\"conditions\":[{\"type\":\"URI\",\"operator\":\"match\",\"value\":\"main\"}]},\"name\":\"main\",\"extractor\":{\"type\":1,\"extractions\":{}}}', '2016-11-08 16:18:59');

-- ----------------------------
-- Table structure for `waf`
-- ----------------------------
DROP TABLE IF EXISTS `waf`;
CREATE TABLE `waf` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL DEFAULT '',
  `value` varchar(2000) NOT NULL DEFAULT '',
  `op_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_waf_key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of waf
-- ----------------------------
INSERT INTO `waf` VALUES ('1', '1294be95-fff9-423f-acae-318a28ccbbe8', '{\"enable\":true,\"handle\":{\"log\":false,\"stat\":true,\"code\":403,\"perform\":\"deny\"},\"time\":\"2016-11-08 16:19:53\",\"judge\":{\"type\":0,\"conditions\":[{\"type\":\"URI\",\"operator\":\"match\",\"value\":\"t\"}]},\"name\":\"t\",\"id\":\"1294be95-fff9-423f-acae-318a28ccbbe8\"}', '2016-11-08 16:19:53');
