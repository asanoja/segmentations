-- phpMyAdmin SQL Dump
-- version 4.1.6
-- http://www.phpmyadmin.net
--
-- Servidor: localhost
-- Tiempo de generación: 09-10-2014 a las 02:36:52
-- Versión del servidor: 5.5.38-0ubuntu0.14.04.1
-- Versión de PHP: 5.5.9-1ubuntu4.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de datos: `bom`
--



--
-- Estructura de tabla para la tabla `algorithms`
--

CREATE TABLE IF NOT EXISTS `algorithms` (
  `id` char(5) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `ord` int(11) NOT NULL,
  `active` tinyint(4) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


--
-- Estructura de tabla para la tabla `algo_browser`
--

CREATE TABLE IF NOT EXISTS `algo_browser` (
  `algo_id` char(5) NOT NULL,
  `browser_id` char(10) NOT NULL,
  PRIMARY KEY (`algo_id`,`browser_id`),
  KEY `browser_id` (`browser_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



--
-- Estructura de tabla para la tabla `blocks`
--

CREATE TABLE IF NOT EXISTS `blocks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `doc_w` double DEFAULT NULL,
  `doc_h` double DEFAULT NULL,
  `bid` varchar(255) DEFAULT NULL,
  `x` double DEFAULT NULL,
  `y` double DEFAULT NULL,
  `w` double DEFAULT NULL,
  `h` double DEFAULT NULL,
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `segmentation_id` int(11) NOT NULL,
  `ecount` int(11) NOT NULL,
  `tcount` int(11) NOT NULL,
  `importance` int(11) NOT NULL,
  `nx` double NOT NULL,
  `ny` double NOT NULL,
  `nw` double NOT NULL,
  `nh` double NOT NULL,
  PRIMARY KEY (`id`),
  KEY `segmentation_id` (`segmentation_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4772 ;



--
-- Estructura de tabla para la tabla `browsers`
--

CREATE TABLE IF NOT EXISTS `browsers` (
  `id` char(10) NOT NULL,
  `long_name` varchar(255) NOT NULL,
  `ord` int(11) NOT NULL,
  `short_name` varchar(255) NOT NULL,
  `active` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Estructura de tabla para la tabla `categories`
--

CREATE TABLE IF NOT EXISTS `categories` (
  `id` char(10) NOT NULL,
  `name` varchar(255) NOT NULL,
  `collection_id` char(4) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Estructura de tabla para la tabla `collection`
--

CREATE TABLE IF NOT EXISTS `collection` (
  `id` char(4) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



--
-- Estructura Stand-in para la vista `corresp`
--
CREATE TABLE IF NOT EXISTS `corresp` (
`algo` char(10)
,`cat` char(10)
,`cc` decimal(14,4)
,`co` decimal(14,4)
,`cu` decimal(14,4)
,`cm` decimal(14,4)
,`cf` decimal(14,4)
,`cq` decimal(14,4)
,`icc` decimal(14,4)
,`ico` decimal(14,4)
,`icu` decimal(14,4)
,`icm` decimal(14,4)
,`icf` decimal(14,4)
,`icq` decimal(14,4)
,`gtb` double
,`ptb` double
);


--
-- Estructura de tabla para la tabla `metrics`
--

CREATE TABLE IF NOT EXISTS `metrics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `page_id` int(11) DEFAULT NULL,
  `cc` int(11) DEFAULT NULL,
  `co` int(11) DEFAULT NULL,
  `cu` int(11) DEFAULT NULL,
  `cf` int(11) DEFAULT NULL,
  `cm` int(11) DEFAULT NULL,
  `cq` int(11) DEFAULT NULL,
  `icc` int(11) DEFAULT NULL,
  `ico` int(11) DEFAULT NULL,
  `icu` int(11) DEFAULT NULL,
  `icm` int(11) DEFAULT NULL,
  `icf` int(11) DEFAULT NULL,
  `icq` int(11) NOT NULL,
  `tt` int(11) DEFAULT NULL,
  `tr` double NOT NULL,
  `ti` double NOT NULL,
  `gtb` double DEFAULT NULL,
  `ptb` double DEFAULT NULL,
  `segmentation1_id` int(11) NOT NULL,
  `segmentation2_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=58810 ;

--
-- Estructura de tabla para la tabla `pages`
--

CREATE TABLE IF NOT EXISTS `pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(255) NOT NULL,
  `category_id` char(10) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `url` (`url`),
  KEY `category_id` (`category_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=252 ;

--
-- Estructura de tabla para la tabla `segmentation`
--

CREATE TABLE IF NOT EXISTS `segmentation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `page_id` int(11) NOT NULL,
  `source1` varchar(255) NOT NULL,
  `source2` varchar(255) NOT NULL,
  `algo` char(10) NOT NULL,
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `granularity` float NOT NULL,
  `browser` char(10) NOT NULL,
  `doc_w` double NOT NULL,
  `doc_h` double NOT NULL,
  `tdcount` int(11) NOT NULL,
  `validated` char(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `browser_2` (`browser`),
  KEY `page_id` (`page_id`),
  KEY `algo` (`algo`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2981 ;

--
-- Estructura de tabla para la tabla `segmentation_data`
--

CREATE TABLE IF NOT EXISTS `segmentation_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `graph_image` blob NOT NULL,
  `graph_src` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;


--
-- Filtros para la tabla `algo_browser`
--
ALTER TABLE `algo_browser`
  ADD CONSTRAINT `algo_browser_ibfk_1` FOREIGN KEY (`algo_id`) REFERENCES `algorithms` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `algo_browser_ibfk_2` FOREIGN KEY (`browser_id`) REFERENCES `browsers` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `blocks`
--
ALTER TABLE `blocks`
  ADD CONSTRAINT `blocks_ibfk_1` FOREIGN KEY (`segmentation_id`) REFERENCES `segmentation` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `categories`
--
ALTER TABLE `categories`
  ADD CONSTRAINT `categories_ibfk_1` FOREIGN KEY (`collection_id`) REFERENCES `collection` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `pages`
--
ALTER TABLE `pages`
  ADD CONSTRAINT `pages_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `segmentation`
--
ALTER TABLE `segmentation`
  ADD CONSTRAINT `segmentation_ibfk_1` FOREIGN KEY (`page_id`) REFERENCES `pages` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `segmentation_ibfk_2` FOREIGN KEY (`browser`) REFERENCES `browsers` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `segmentation_ibfk_3` FOREIGN KEY (`algo`) REFERENCES `algorithms` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
