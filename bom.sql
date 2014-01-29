-- phpMyAdmin SQL Dump
-- version 3.4.11.1deb1
-- http://www.phpmyadmin.net
--
-- Servidor: localhost
-- Tiempo de generación: 29-01-2014 a las 19:06:32
-- Versión del servidor: 5.1.61
-- Versión de PHP: 5.3.10-1

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de datos: `bom`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `algorithms`
--

CREATE TABLE IF NOT EXISTS `algorithms` (
  `id` char(5) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `algorithms`
--

INSERT INTO `algorithms` (`id`, `name`) VALUES
('BOM', 'BOM'),
('VIPS', 'VIPS'),
('GT', 'GT'),
('BF', 'BlockFusion'),
('JVIPS', 'VIPS Java');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bf_blocks`
--

CREATE TABLE IF NOT EXISTS `bf_blocks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `browser` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `doc_w` double DEFAULT NULL,
  `doc_h` double DEFAULT NULL,
  `bid` varchar(255) DEFAULT NULL,
  `block_x` double DEFAULT NULL,
  `block_y` double DEFAULT NULL,
  `block_w` double DEFAULT NULL,
  `block_h` double DEFAULT NULL,
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `segmentation_id` int(11) NOT NULL,
  `ecount` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=475 ;



--
-- Estructura de tabla para la tabla `bom_blocks`
--

CREATE TABLE IF NOT EXISTS `bom_blocks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `browser` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `doc_w` double DEFAULT NULL,
  `doc_h` double DEFAULT NULL,
  `bid` varchar(255) DEFAULT NULL,
  `block_x` double DEFAULT NULL,
  `block_y` double DEFAULT NULL,
  `block_w` double DEFAULT NULL,
  `block_h` double DEFAULT NULL,
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `segmentation_id` int(11) NOT NULL,
  `ecount` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1419 ;


--
-- Estructura de tabla para la tabla `gt_blocks`
--

CREATE TABLE IF NOT EXISTS `gt_blocks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `browser` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `doc_w` double DEFAULT NULL,
  `doc_h` double DEFAULT NULL,
  `bid` varchar(255) DEFAULT NULL,
  `block_x` double DEFAULT NULL,
  `block_y` double DEFAULT NULL,
  `block_w` double DEFAULT NULL,
  `block_h` double DEFAULT NULL,
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `segmentation_id` int(11) NOT NULL,
  `ecount` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=206 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `jvips_blocks`
--

CREATE TABLE IF NOT EXISTS `jvips_blocks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `browser` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `doc_w` double DEFAULT NULL,
  `doc_h` double DEFAULT NULL,
  `bid` varchar(255) DEFAULT NULL,
  `block_x` double DEFAULT NULL,
  `block_y` double DEFAULT NULL,
  `block_w` double DEFAULT NULL,
  `block_h` double DEFAULT NULL,
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `segmentation_id` int(11) NOT NULL,
  `ecount` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=466 ;



--
-- Estructura de tabla para la tabla `metrics`
--

CREATE TABLE IF NOT EXISTS `metrics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `tc` double DEFAULT NULL,
  `to` double DEFAULT NULL,
  `tu` double DEFAULT NULL,
  `co` double DEFAULT NULL,
  `cu` double DEFAULT NULL,
  `cf` double DEFAULT NULL,
  `cm` double DEFAULT NULL,
  `tt` int(11) DEFAULT NULL,
  `gtb` double DEFAULT NULL,
  `stb` double DEFAULT NULL,
  `algo1` char(5) NOT NULL,
  `algo2` char(5) NOT NULL,
  `browser1` varchar(30) NOT NULL,
  `browser2` varchar(30) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=594 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `segmentation`
--

CREATE TABLE IF NOT EXISTS `segmentation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` text NOT NULL,
  `source1` varchar(255) NOT NULL,
  `source2` varchar(255) NOT NULL,
  `kind` varchar(255) NOT NULL,
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `wprima` text,
  `granularity` float NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=278 ;



--
-- Estructura de tabla para la tabla `vips_blocks`
--

CREATE TABLE IF NOT EXISTS `vips_blocks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `browser` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `doc_w` double DEFAULT NULL,
  `doc_h` double DEFAULT NULL,
  `bid` varchar(255) DEFAULT NULL,
  `block_x` double DEFAULT NULL,
  `block_y` double DEFAULT NULL,
  `block_w` double DEFAULT NULL,
  `block_h` double DEFAULT NULL,
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `segmentation_id` int(11) NOT NULL,
  `ecount` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=115 ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
