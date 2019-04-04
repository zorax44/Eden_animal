USE `essentialmode`;

INSERT INTO `shops` (`store`, `item`, `price`) VALUES
	('LTDgasoline', 'croquettes', 100)
;

INSERT INTO `items` (name, label) VALUES
	('croquettes', 'Croquettes')
;

DROP TABLE IF EXISTS `pet`;
CREATE TABLE IF NOT EXISTS `pet` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
    `identifier` varchar(255) NOT NULL,
    `name` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
    `licenses` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
    `status` longtext CHARACTER SET utf8,
    `dead` varchar(250) DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `IsDead` (`identifier`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

COMMIT;
